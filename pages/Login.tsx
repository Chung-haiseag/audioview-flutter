import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { HelpCircle, ChevronLeft, Eye, EyeOff } from 'lucide-react';

interface LoginProps {
  onLogin: () => void;
}

const Login: React.FC<LoginProps> = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    
    // 로딩 시뮬레이션
    setTimeout(() => {
      onLogin();
      setIsLoading(false);
      navigate('/settings'); // 로그인 성공 후 설정 메뉴로 복귀
    }, 1500);
  };

  return (
    <div className="fixed inset-0 z-[200] bg-black flex flex-col font-sans overflow-hidden animate-fadeIn">
      {/* 배경 이미지 레이어 */}
      <div className="absolute inset-0 z-0 overflow-hidden">
        <div className="grid grid-cols-3 gap-1 opacity-20 scale-110">
          {[...Array(12)].map((_, i) => (
            <img 
              key={i} 
              src={`https://picsum.photos/seed/${i + 50}/300/450`} 
              className="w-full aspect-[2/3] object-cover" 
              alt="" 
            />
          ))}
        </div>
        <div className="absolute inset-0 bg-gradient-to-b from-black/80 via-black/40 to-black"></div>
      </div>

      {/* 헤더 영역 - 뒤로가기 버튼 추가 */}
      <header className="relative z-10 px-6 py-6 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <button 
            onClick={() => navigate(-1)} 
            className="p-2 -ml-2 text-white hover:bg-white/10 rounded-full transition-colors active:scale-90"
            aria-label="뒤로가기"
          >
            <ChevronLeft size={32} />
          </button>
          <h1 className="text-2xl font-black tracking-tighter text-[#E50914] uppercase italic select-none">
            AUDIOVIEW
          </h1>
        </div>
      </header>

      {/* 로그인 폼 */}
      <main className="relative z-10 flex-1 flex flex-col justify-center px-8 pb-20 max-w-md mx-auto w-full">
        <h2 className="text-3xl font-bold text-white mb-8">로그인</h2>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="relative group">
            <input 
              type="text"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              aria-label="이메일 또는 전화번호"
              className="w-full bg-[#333] border-none rounded-md px-4 pt-6 pb-2 text-white text-base focus:ring-2 focus:ring-[#E50914] focus:bg-[#444] transition-all peer placeholder-transparent"
              placeholder="email"
            />
            <label 
              htmlFor="email"
              className="absolute left-4 top-2 text-gray-400 text-xs font-bold transition-all peer-placeholder-shown:top-4 peer-placeholder-shown:text-base peer-placeholder-shown:font-normal peer-focus:top-2 peer-focus:text-xs peer-focus:font-bold"
            >
              이메일 주소 또는 전화번호
            </label>
          </div>

          <div className="relative group">
            <input 
              type={showPassword ? "text" : "password"}
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              aria-label="비밀번호"
              className="w-full bg-[#333] border-none rounded-md px-4 pt-6 pb-2 text-white text-base focus:ring-2 focus:ring-[#E50914] focus:bg-[#444] transition-all peer placeholder-transparent"
              placeholder="password"
            />
            <label 
              htmlFor="password"
              className="absolute left-4 top-2 text-gray-400 text-xs font-bold transition-all peer-placeholder-shown:top-4 peer-placeholder-shown:text-base peer-placeholder-shown:font-normal peer-focus:top-2 peer-focus:text-xs peer-focus:font-bold"
            >
              비밀번호
            </label>
            <button 
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-500 mt-2"
            >
              {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
            </button>
          </div>

          <button 
            type="submit"
            disabled={isLoading}
            className="w-full bg-[#E50914] text-white py-4 rounded-md font-bold text-lg mt-4 active:scale-[0.98] transition-all flex items-center justify-center disabled:bg-red-800 disabled:active:scale-100 shadow-lg shadow-red-900/20"
          >
            {isLoading ? (
              <div className="w-6 h-6 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
            ) : "로그인"}
          </button>
        </form>

        <div className="mt-6 flex flex-col items-center gap-4">
          <button className="text-gray-400 text-sm hover:underline">비밀번호를 잊으셨나요?</button>
          
          <div className="flex items-center gap-2 mt-4 text-center flex-wrap justify-center">
            <span className="text-gray-500">AudioView 회원이 아닌가요?</span>
            <button className="text-white font-bold hover:underline">지금 가입하세요.</button>
          </div>
        </div>
      </main>

      {/* 푸터 정보 */}
      <footer className="relative z-10 px-8 py-10 border-t border-white/10 bg-black/80 mt-auto">
        <button className="flex items-center gap-2 text-gray-500 text-sm mb-6 text-left">
          <HelpCircle size={16} className="shrink-0" />
          <span>문의 사항이 있으신가요? 고객 센터에 문의하세요.</span>
        </button>
        <div className="grid grid-cols-2 gap-y-4 text-[11px] text-gray-600">
          <span>이용 약관</span>
          <span>개인정보 처리방침</span>
          <span>쿠키 설정</span>
          <span>회사 정보</span>
        </div>
      </footer>
    </div>
  );
};

export default Login;