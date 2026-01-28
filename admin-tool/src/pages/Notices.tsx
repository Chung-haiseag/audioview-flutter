import React, { useEffect, useState } from 'react';
import {
    Box,
    Typography,
    Button,
    Paper,
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    IconButton,
    Chip,
    TextField,
    InputAdornment,
    CircularProgress,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    FormControlLabel,
    Checkbox,
    MenuItem,
    Select,
    FormControl,
    InputLabel,
    Grid,
    Divider,
} from '@mui/material';
import {
    Add as AddIcon,
    Edit as EditIcon,
    Delete as DeleteIcon,
    Search as SearchIcon,

    PriorityHigh as PriorityHighIcon,
} from '@mui/icons-material';
import { getNotices, addNotice, updateNotice, deleteNotice } from '../services/noticeService';
import { Notice } from '../types';
import { format } from 'date-fns';
import { auth } from '../services/firebase';
import MovieSelector from '../components/MovieSelector';

const Notices: React.FC = () => {
    const [notices, setNotices] = useState<Notice[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');

    // 다이얼로그 상태
    const [openDialog, setOpenDialog] = useState(false);
    const [editingNotice, setEditingNotice] = useState<Notice | null>(null);
    const [formData, setFormData] = useState<Partial<Notice>>({
        title: '',
        content: '',
        noticeType: 'general',
        isImportant: false,
        publishedAt: new Date(),
        movieId: '',
    });

    useEffect(() => {
        fetchNotices();
    }, []);

    const fetchNotices = async () => {
        try {
            setLoading(true);
            const data = await getNotices();
            setNotices(data);
        } catch (error) {
            console.error('공지사항 목록 조회 오류:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleOpenAdd = () => {
        setEditingNotice(null);
        setFormData({
            title: '',
            content: '',
            noticeType: 'general',
            isImportant: false,
            publishedAt: new Date(),
            movieId: '',
        });
        setOpenDialog(true);
    };

    const handleOpenEdit = (notice: Notice) => {
        setEditingNotice(notice);
        setFormData({ ...notice });
        setOpenDialog(true);
    };

    const handleCloseDialog = () => {
        setOpenDialog(false);
    };

    const handleDelete = async (noticeId: string) => {
        if (window.confirm('정말로 이 공지사항을 삭제하시겠습니까?')) {
            try {
                await deleteNotice(noticeId);
                fetchNotices();
            } catch (error) {
                console.error('공지사항 삭제 오류:', error);
                alert('삭제 중 오류가 발생했습니다.');
            }
        }
    };

    const handleSubmit = async () => {
        const currentUser = auth.currentUser;
        if (!currentUser) {
            alert('인증 정보가 없습니다. 다시 로그인해 주세요.');
            return;
        }

        try {
            const isPushRequested = formData.pushTitle !== undefined;
            const notificationData = {
                ...formData,
                push_enabled: isPushRequested,
            };

            console.log('공지사항 저장 데이터:', notificationData);

            if (editingNotice) {
                await updateNotice(editingNotice.noticeId, notificationData);
            } else {
                await addNotice(
                    notificationData as any,
                    currentUser.uid
                );
            }
            handleCloseDialog();
            fetchNotices();
        } catch (error) {
            console.error('공지사항 저장 오류:', error);
            alert('저장 중 오류가 발생했습니다.');
        }
    };

    const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | { name?: string; value: unknown }>) => {
        const { name, value } = e.target;
        const checked = (e.target as HTMLInputElement).checked;
        const type = (e.target as HTMLInputElement).type;

        setFormData((prev) => ({
            ...prev,
            [name as string]: type === 'checkbox' ? checked : value,
        }));
    };

    const filteredNotices = notices.filter(
        (notice) =>
            notice.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
            notice.content.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const getNoticeTypeChip = (type: string) => {
        switch (type) {
            case 'maintenance': return <Chip label="점검" size="small" color="warning" />;
            case 'event': return <Chip label="이벤트" size="small" color="success" />;
            default: return <Chip label="일반" size="small" />;
        }
    };

    return (
        <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Typography variant="h4" fontWeight="bold">
                    공지사항 관리
                </Typography>
                <Button variant="contained" startIcon={<AddIcon />} onClick={handleOpenAdd}>
                    공지사항 작성
                </Button>
            </Box>

            <Paper sx={{ p: 2, mb: 2 }}>
                <TextField
                    fullWidth
                    placeholder="제목 또는 내용 검색..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    InputProps={{
                        startAdornment: (
                            <InputAdornment position="start">
                                <SearchIcon />
                            </InputAdornment>
                        ),
                    }}
                />
            </Paper>

            {loading ? (
                <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
                    <CircularProgress />
                </Box>
            ) : (
                <TableContainer component={Paper}>
                    <Table>
                        <TableHead>
                            <TableRow>
                                <TableCell width="80">중요</TableCell>
                                <TableCell width="100">분류</TableCell>
                                <TableCell>제목</TableCell>
                                <TableCell width="150">연결 영화 ID</TableCell>
                                <TableCell width="120">조회수</TableCell>
                                <TableCell width="150">게시일</TableCell>
                                <TableCell width="120" align="center">액션</TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {filteredNotices.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={6} align="center">
                                        <Typography variant="body2" color="text.secondary">
                                            공지사항이 없습니다
                                        </Typography>
                                    </TableCell>
                                </TableRow>
                            ) : (
                                filteredNotices.map((notice) => (
                                    <TableRow key={notice.noticeId} hover>
                                        <TableCell>
                                            {notice.isImportant && (
                                                <PriorityHighIcon color="error" fontSize="small" />
                                            )}
                                        </TableCell>
                                        <TableCell>
                                            {getNoticeTypeChip(notice.noticeType)}
                                        </TableCell>
                                        <TableCell>
                                            <Typography variant="body2" fontWeight={notice.isImportant ? "bold" : "regular"}>
                                                {notice.title}
                                            </Typography>
                                        </TableCell>
                                        <TableCell>
                                            <Typography variant="caption" color="text.secondary">
                                                {notice.movieId || '-'}
                                            </Typography>
                                        </TableCell>
                                        <TableCell>{notice.viewCount || 0}</TableCell>
                                        <TableCell>
                                            {notice.publishedAt ? format(notice.publishedAt, 'yyyy-MM-dd') : '-'}
                                        </TableCell>
                                        <TableCell align="center">
                                            <IconButton size="small" color="primary" onClick={() => handleOpenEdit(notice)}>
                                                <EditIcon />
                                            </IconButton>
                                            <IconButton size="small" color="error" onClick={() => handleDelete(notice.noticeId)}>
                                                <DeleteIcon />
                                            </IconButton>
                                        </TableCell>
                                    </TableRow>
                                ))
                            )}
                        </TableBody>
                    </Table>
                </TableContainer>
            )}

            {/* 공지사항 작성/수정 다이얼로그 */}
            <Dialog open={openDialog} onClose={handleCloseDialog} maxWidth="md" fullWidth>
                <DialogTitle>{editingNotice ? '공지사항 수정' : '새 공지사항 작성'}</DialogTitle>
                <DialogContent dividers>
                    <Grid container spacing={2} sx={{ mt: 0.5 }}>
                        <Grid size={{ xs: 12, sm: 8 }}>
                            <TextField
                                fullWidth
                                label="공지 제목"
                                name="title"
                                value={formData.title}
                                onChange={handleInputChange}
                                required
                            />
                        </Grid>
                        <Grid size={{ xs: 12, sm: 4 }}>
                            <FormControl fullWidth>
                                <InputLabel>공지 종류</InputLabel>
                                <Select
                                    name="noticeType"
                                    value={formData.noticeType}
                                    label="공지 종류"
                                    onChange={(e) => setFormData(prev => ({ ...prev, noticeType: e.target.value as any }))}
                                >
                                    <MenuItem value="general">일반</MenuItem>
                                    <MenuItem value="maintenance">점검</MenuItem>
                                    <MenuItem value="event">이벤트</MenuItem>
                                    <MenuItem value="important">중요</MenuItem>
                                </Select>
                            </FormControl>
                        </Grid>
                        <Grid size={12}>
                            <TextField
                                fullWidth
                                label="공지 내용"
                                name="content"
                                value={formData.content}
                                onChange={handleInputChange}
                                multiline
                                rows={10}
                                required
                            />
                        </Grid>
                        <Grid size={{ xs: 12, sm: 6 }}>
                            <TextField
                                fullWidth
                                label="게시 일자"
                                name="publishedAt"
                                type="date"
                                value={formData.publishedAt instanceof Date && !isNaN(formData.publishedAt.getTime()) ? format(formData.publishedAt, 'yyyy-MM-dd') : ''}
                                onChange={(e) => setFormData(prev => ({ ...prev, publishedAt: new Date(e.target.value) }))}
                                InputLabelProps={{ shrink: true }}
                            />
                        </Grid>
                        <Grid size={{ xs: 12, sm: 6 }}>
                            <MovieSelector
                                value={formData.movieId}
                                onChange={(movieId) => setFormData(prev => ({ ...prev, movieId }))}
                            />
                        </Grid>
                        <Grid size={12}>
                            <Divider sx={{ my: 1 }}>푸시 알림 설정 (선택 사항)</Divider>
                        </Grid>
                        <Grid size={12}>
                            <FormControlLabel
                                control={
                                    <Checkbox
                                        name="sendPush"
                                        checked={formData.pushTitle !== undefined || false}
                                        onChange={(e) => {
                                            const checked = e.target.checked;
                                            setFormData(prev => ({
                                                ...prev,
                                                pushTitle: checked ? (prev.title || '') : undefined,
                                                pushMessage: checked ? (prev.content?.substring(0, 100) || '') : undefined,
                                                isPushSent: checked ? false : prev.isPushSent
                                            }));
                                        }}
                                    />
                                }
                                label="저장 시 푸시 알림 즉시 전송"
                            />
                        </Grid>
                        {(formData.pushTitle !== undefined) && (
                            <>
                                <Grid size={12}>
                                    <TextField
                                        fullWidth
                                        label="푸시 제목 (미입력 시 공지 제목 사용)"
                                        name="pushTitle"
                                        value={formData.pushTitle}
                                        onChange={handleInputChange}
                                        size="small"
                                    />
                                </Grid>
                                <Grid size={12}>
                                    <TextField
                                        fullWidth
                                        label="푸시 내용 (미입력 시 공지 내용 요약 사용)"
                                        name="pushMessage"
                                        value={formData.pushMessage}
                                        onChange={handleInputChange}
                                        multiline
                                        rows={2}
                                        size="small"
                                    />
                                </Grid>
                            </>
                        )}
                    </Grid>
                </DialogContent>
                <DialogActions>
                    <Button onClick={handleCloseDialog}>취소</Button>
                    <Button onClick={handleSubmit} variant="contained" color="primary">
                        저장
                    </Button>
                </DialogActions>
            </Dialog>
        </Box>
    );
};

export default Notices;
