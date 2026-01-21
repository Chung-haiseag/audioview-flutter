
import React, { useState, useEffect, useMemo, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
// Added GripHorizontal to the imports to resolve the error on line 231
import { ChevronLeft, Disc, X, Pause, Play, Settings, Glasses, AlertCircle, GripVertical, GripHorizontal, CheckCircle, Type, MoreVertical } from 'lucide-react';
import { MOCK_MOVIES } from '../constants';

const FONT_SIZES = ['small', 'medium', 'large', 'xlarge'];
const FONT_LABELS: Record<string, string> = {
  small: '작게',
  medium: '보통',
  large: '크게',
  xlarge: '매우 크게'
};

const MovieDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const movie = MOCK_MOVIES.find((m) => m.id === id) || MOCK_MOVIES[0];

  const [viewState, setViewState] = useState<'selection' | 'syncing' | 'complete' | 'playing'>('selection');
  const [adSelected, setAdSelected] = useState(false);
  const [ccSelected, setCcSelected] = useState(false);
  const [isPlaying, setIsPlaying] = useState(true);
  const [isGlassesConnected, setIsGlassesConnected] = useState(true);

  // Subtitle Style State
  const [currentFontSize, setCurrentFontSize] = useState(() => localStorage.getItem('captionFontSize') || 'medium');
  const [showSizeHUD, setShowSizeHUD] = useState(false);
  const hudTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Drag & Drop State
  const [isDragging, setIsDragging] = useState(false);
  const [verticalOffset, setVerticalOffset] = useState(() => {
    const saved = localStorage.getItem('captionVerticalOffset');
    return saved ? parseFloat(saved) : 70; 
  });
  const containerRef = useRef<HTMLDivElement>(null);

  // Memoized styles
  const captionStyles = useMemo(() => {
    const color = localStorage.getItem('captionFontColor') || '#FFFFFF';
    const opacity = Number(localStorage.getItem('captionBgOpacity')) ?? 0.5;
    
    const fontScaleMap: Record<string, string> = {
      small: '1.2rem',
      medium: '1.6rem',
      large: '2.2rem',
      xlarge: '2.8rem'
    };

    return {
      fontSize: fontScaleMap[currentFontSize],
      color,
      backgroundColor: `rgba(0, 0, 0, ${opacity})`
    };
  }, [currentFontSize, viewState]);

  // Orientation Management
  useEffect(() => {
    if (viewState === 'playing' && ccSelected) {
      if (document.documentElement.requestFullscreen) {
        document.documentElement.requestFullscreen().catch(() => {});
      }
      if (screen.orientation && (screen.orientation as any).lock) {
        (screen.orientation as any).lock('landscape').catch(() => {});
      }
    } else {
      if (document.fullscreenElement && document.exitFullscreen) {
        document.exitFullscreen().catch(() => {});
      }
      if (screen.orientation && screen.orientation.unlock) {
        screen.orientation.unlock();
      }
    }
  }, [viewState, ccSelected]);

  // Volume Button Listener for Font Size
  useEffect(() => {
    if (viewState !== 'playing') return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'AudioVolumeUp' || e.key === 'VolumeUp' || e.key === 'ArrowUp') {
        e.preventDefault();
        adjustFontSize(1);
      } else if (e.key === 'AudioVolumeDown' || e.key === 'VolumeDown' || e.key === 'ArrowDown') {
        e.preventDefault();
        adjustFontSize(-1);
      }
    };

    const adjustFontSize = (direction: number) => {
      const currentIndex = FONT_SIZES.indexOf(currentFontSize);
      const nextIndex = Math.max(0, Math.min(FONT_SIZES.length - 1, currentIndex + direction));
      const nextSize = FONT_SIZES[nextIndex];
      
      if (nextSize !== currentFontSize) {
        setCurrentFontSize(nextSize);
        localStorage.setItem('captionFontSize', nextSize);
        
        setShowSizeHUD(true);
        if (hudTimerRef.current) clearTimeout(hudTimerRef.current);
        hudTimerRef.current = setTimeout(() => setShowSizeHUD(false), 2000);
        
        if (typeof navigator !== 'undefined' && navigator.vibrate) {
          navigator.vibrate(30);
        }
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [currentFontSize, viewState]);

  useEffect(() => {
    let timer: ReturnType<typeof setTimeout>;
    if (viewState === 'syncing') {
        if (typeof navigator !== 'undefined' && navigator.vibrate) {
            navigator.vibrate([50, 50, 50]);
        }
        timer = setTimeout(() => { setViewState('complete'); }, 2000);
    } else if (viewState === 'complete') {
        timer = setTimeout(() => { setViewState('playing'); }, 800);
    }
    return () => clearTimeout(timer);
  }, [viewState]);

  const handleStartAD = () => {
    setAdSelected(true);
    setCcSelected(false);
    setViewState('syncing'); 
  };

  const handleStartCC = () => {
    setAdSelected(false);
    setCcSelected(true);
    setViewState('syncing');
  };

  const onDragStart = (e: React.MouseEvent | React.TouchEvent) => {
    setIsDragging(true);
  };

  const onDrag = (e: MouseEvent | TouchEvent) => {
    if (!isDragging || !containerRef.current) return;
    const containerRect = containerRef.current.getBoundingClientRect();
    const clientY = 'touches' in e ? e.touches[0].clientY : e.clientY;
    let newY = ((clientY - containerRect.top) / containerRect.height) * 100;
    newY = Math.max(10, Math.min(90, newY));
    setVerticalOffset(newY);
  };

  const onDragEnd = () => {
    if (isDragging) {
      setIsDragging(false);
      localStorage.setItem('captionVerticalOffset', verticalOffset.toString());
    }
  };

  useEffect(() => {
    if (isDragging) {
      window.addEventListener('mousemove', onDrag);
      window.addEventListener('mouseup', onDragEnd);
      window.addEventListener('touchmove', onDrag, { passive: false });
      window.addEventListener('touchend', onDragEnd);
    }
    return () => {
      window.removeEventListener('mousemove', onDrag);
      window.removeEventListener('mouseup', onDragEnd);
      window.removeEventListener('touchmove', onDrag);
      window.removeEventListener('touchend', onDragEnd);
    };
  }, [isDragging]);

  if (!movie) return null;

  // 1. 재생 중 화면 (Playing State)
  if (viewState === 'playing') {
      return (
        <div className="fixed inset-0 z-[100] bg-brand-dark flex flex-col font-sans select-none overflow-hidden animate-fadeIn">
            {/* Font Size HUD */}
            <div className={`fixed top-20 left-1/2 -translate-x-1/2 z-[110] transition-all duration-300 pointer-events-none ${showSizeHUD ? 'opacity-100 translate-y-0' : 'opacity-0 -translate-y-4'}`}>
               <div className="bg-black/90 backdrop-blur-md border border-white/20 px-6 py-3 rounded-2xl flex items-center gap-4 shadow-2xl">
                  <Type size={20} className="text-[#E50914]" />
                  <div className="flex flex-col">
                    <span className="text-[10px] text-gray-400 font-bold uppercase tracking-wider">자막 크기</span>
                    <span className="text-white font-black text-sm">{FONT_LABELS[currentFontSize]}</span>
                  </div>
               </div>
            </div>

            {/* Top Navigation - Matching Image */}
            <div className="flex items-center justify-between px-5 py-5 bg-brand-dark/40 backdrop-blur-sm z-20">
                <div className="flex items-center">
                    <button onClick={() => setViewState('selection')} className="text-white mr-4">
                        <ChevronLeft size={30} />
                    </button>
                    <div>
                        <h2 className="text-white font-bold text-lg leading-tight tracking-tight">{movie.title}</h2>
                        <div className="flex items-center gap-1.5 mt-0.5">
                            <span className="w-2.5 h-2.5 bg-red-600 rounded-full animate-pulse"></span>
                            <span className="text-red-500 text-[11px] font-bold">실시간 동기화 중</span>
                        </div>
                    </div>
                </div>
                <div className="flex items-center gap-4">
                    <div className="bg-green-500/10 border border-green-500/50 rounded-lg px-2.5 py-1 flex items-center gap-1.5">
                        <Glasses size={14} className="text-green-500" />
                        <span className="text-green-500 text-[11px] font-bold">글래스 연결됨</span>
                    </div>
                    <button onClick={() => navigate('/settings')} className="text-gray-400 hover:text-white transition-colors">
                        <Settings size={28} />
                    </button>
                </div>
            </div>

            {/* Subtitle / Background Area */}
            <div ref={containerRef} className="flex-1 relative overflow-hidden">
                <div className="absolute inset-0 opacity-10 pointer-events-none">
                    <img src={movie.posterUrl} className="w-full h-full object-cover blur-md" alt="" />
                </div>

                {/* Subtitle Box - Styling matching the image */}
                <div 
                  className={`absolute left-8 right-8 z-10 transition-transform duration-75 ${isDragging ? 'scale-[1.02]' : ''}`}
                  style={{ top: `${verticalOffset}%`, transform: 'translateY(-50%)' }}
                >
                    <div 
                        className="relative p-7 bg-black/40 rounded-2xl border-l-[6px] border-[#E50914] shadow-2xl mx-auto max-w-4xl"
                        style={{ width: '100%' }}
                    >
                        <div onMouseDown={onDragStart} onTouchStart={onDragStart} className="absolute -top-3 left-1/2 -translate-x-1/2 cursor-grab active:cursor-grabbing opacity-0 group-hover:opacity-100 transition-opacity">
                            <GripHorizontal size={20} className="text-gray-500" />
                        </div>
                        <span className="text-gray-400 text-sm font-bold mb-3 block">대사</span>
                        <p 
                            className="text-white font-black leading-tight tracking-tight text-center sm:text-left"
                            style={{ fontSize: captionStyles.fontSize }}
                        >
                            "대체 여기서 무슨 일이 벌어지고 있는 거야?"
                        </p>
                    </div>
                </div>

                {/* Guide Text - Matching Image Center */}
                {!isDragging && (
                  <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 opacity-30 pointer-events-none text-center flex flex-col items-center gap-4">
                    <div className="grid grid-cols-3 gap-1 mb-2">
                        {[...Array(9)].map((_, i) => <div key={i} className="w-1.5 h-1.5 bg-white rounded-full"></div>)}
                    </div>
                    <p className="text-xs font-medium text-white tracking-widest uppercase">드래그로 위치 조절</p>
                    <div className="flex items-center gap-2 mt-2">
                        <Type size={14} />
                        <p className="text-xs font-medium text-white tracking-widest uppercase">볼륨 버튼으로 크기 조절</p>
                    </div>
                  </div>
                )}
            </div>

            {/* Player Controls - Matching Image Bottom */}
            <div className="bg-[#0A0A0A] border-t border-white/5 px-8 pt-8 pb-12 z-20">
                 <div className="flex items-center justify-between mb-6">
                    <span className="text-[11px] text-gray-500 font-mono">00:15:24</span>
                    <div className="h-1 flex-1 mx-6 bg-gray-800 rounded-full overflow-hidden relative">
                        <div className="h-full w-[30%] bg-[#E50914]"></div>
                    </div>
                    <span className="text-[11px] text-gray-500 font-mono">01:42:10</span>
                 </div>
                 
                 <div className="flex items-center justify-center gap-12 sm:gap-20">
                    <button className="text-gray-500 hover:text-white transition-colors">
                        <Disc size={32}/>
                    </button>
                    <button 
                        onClick={() => setIsPlaying(!isPlaying)} 
                        className="w-20 h-20 bg-white rounded-full flex items-center justify-center text-black active:scale-95 transition-transform shadow-2xl"
                    >
                        {isPlaying ? <Pause size={44} fill="black" /> : <Play size={44} fill="black" className="ml-1.5"/>}
                    </button>
                    <button className="text-gray-500 hover:text-white transition-colors" onClick={() => setViewState('selection')}>
                        <X size={32}/>
                    </button>
                 </div>
            </div>
        </div>
      );
  }

  // 2. 동기화 중 화면
  if (viewState === 'syncing' || viewState === 'complete') {
     return (
        <div className="fixed inset-0 z-[100] bg-brand-dark flex flex-col items-center justify-center font-sans animate-fadeIn overflow-hidden">
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-red-900/20 via-brand-dark to-brand-dark"></div>
            <div className="relative z-10 flex flex-col items-center w-full px-8">
                <div className="relative w-64 h-64 flex items-center justify-center mb-16">
                    <div className={`absolute inset-0 rounded-full border border-white/5 ${viewState === 'syncing' ? 'animate-[spin_10s_linear_infinite]' : ''}`}></div>
                    <div className={`absolute w-40 h-40 rounded-full bg-[#E50914] blur-[60px] opacity-60 ${viewState === 'syncing' ? 'animate-pulse' : 'scale-150 transition-transform duration-700'}`}></div>
                    
                    {viewState === 'syncing' ? (
                        <div className="flex items-end justify-center gap-1.5 h-24 mb-2">
                            {[...Array(9)].map((_, i) => (
                                <div key={i} className="w-2 bg-gradient-to-t from-[#E50914] to-red-400 rounded-full animate-[bounce_1.2s_infinite]" style={{ height: `${Math.max(20, Math.random() * 100)}%`, animationDelay: `${i * 0.1}s` }} />
                            ))}
                        </div>
                    ) : (
                        <div className="animate-scaleIn">
                            <CheckCircle size={80} className="text-white" />
                        </div>
                    )}
                </div>
                <h2 className="text-3xl font-black text-white mb-3">
                    {viewState === 'syncing' ? '실시간 동기화 중' : '동기화 완료'}
                </h2>
                <p className="text-gray-400 text-sm text-center">
                    영화 소리를 분석하여 최적의 지점을 찾고 있습니다.
                </p>
            </div>
            <button onClick={() => setViewState('selection')} className="absolute top-6 right-6 p-4 rounded-full bg-white/5 backdrop-blur-md text-white/50"><X size={28} /></button>
        </div>
     )
  }

  // 3. 작품 선택 화면 (Portrait Netflix Style)
  return (
    <div className="relative w-full h-[calc(100vh-68px)] overflow-hidden bg-brand-dark text-white font-sans animate-fadeIn">
      <div className="absolute inset-0 z-0 scale-105 transition-transform duration-[10s] ease-linear">
          <img src={movie.posterUrl} alt={movie.title} className="w-full h-full object-cover opacity-50" />
          <div className="absolute inset-0 bg-gradient-to-t from-brand-dark via-brand-dark/40 to-transparent" />
      </div>

      <div className="absolute top-6 left-6 z-20">
        <button onClick={() => navigate(-1)} className="p-3 rounded-full bg-black/50 backdrop-blur-md text-white border border-white/10 active:scale-90 transition-all">
          <ChevronLeft size={30} />
        </button>
      </div>

      <div className="absolute bottom-0 left-0 right-0 z-10 px-6 pb-24 flex flex-col justify-end h-full">
         <div className="w-full max-w-md mx-auto text-center">
             <h1 className="text-4xl font-black mb-6 tracking-tighter drop-shadow-2xl">{movie.title}</h1>
             <div className="flex items-center justify-center space-x-4 text-xs font-bold text-gray-300 mb-12">
                <span>{movie.year}</span>
                <span className="bg-[#E50914] px-1.5 py-0.5 rounded text-[10px] text-white">HD</span>
                <span>{movie.duration}분</span>
             </div>

             <div className="grid grid-cols-2 gap-5 w-full">
                <button 
                    onClick={handleStartAD}
                    className="flex flex-col items-center justify-center bg-white/10 backdrop-blur-xl border border-white/10 rounded-2xl p-8 hover:bg-[#E50914] transition-all group"
                >
                    <div className="w-14 h-14 rounded-full bg-black/40 flex items-center justify-center mb-4 border border-white/20 group-hover:bg-white group-hover:text-black">
                        <Disc size={32} />
                    </div>
                    <span className="text-sm font-bold">화면해설(AD)</span>
                </button>

                <button 
                    onClick={handleStartCC}
                    className="flex flex-col items-center justify-center bg-white/10 backdrop-blur-xl border border-white/10 rounded-2xl p-8 hover:bg-[#E50914] transition-all group"
                >
                    <div className="w-14 h-14 rounded-full bg-black/40 flex items-center justify-center mb-4 border border-white/20 group-hover:bg-white group-hover:text-black">
                        <span className="text-xl font-black">CC</span>
                    </div>
                    <span className="text-sm font-bold">문자자막(CC)</span>
                </button>
             </div>
         </div>
      </div>
    </div>
  );
};

export default MovieDetail;
