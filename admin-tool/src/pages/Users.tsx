import React, { useEffect, useState } from 'react';
import {
    Box,
    Typography,
    Paper,
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    Chip,
    TextField,
    InputAdornment,
    CircularProgress,
    IconButton,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    Button,
    Grid,
    Divider,
    Switch,
    FormControlLabel,
    Tabs,
    Tab,
    List,
    ListItem,
    ListItemText,
} from '@mui/material';
import {
    Search as SearchIcon,
    Visibility as VisibilityIcon,
    Add as AddIcon,
    Edit as EditIcon,
    Delete as DeleteIcon,
} from '@mui/icons-material';
import { getUsers, updateUser, getUserFavorites, getUserDownloadHistory, addUser, deleteUser, getUserPoints, getPointHistory } from '../services/userService';
import { User, UserFavorite, UserDownloadHistory, UserPoint, PointHistory } from '../types';
import { format } from 'date-fns';

const Users: React.FC = () => {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');

    // 상세 정보 다이얼로그 상태
    const [openDetail, setOpenDetail] = useState(false);
    const [selectedUser, setSelectedUser] = useState<User | null>(null);

    // 탭 및 활동 데이터 상태
    const [tabValue, setTabValue] = useState(0);
    const [favorites, setFavorites] = useState<UserFavorite[]>([]);
    const [downloadHistory, setDownloadHistory] = useState<UserDownloadHistory[]>([]);
    const [userPoint, setUserPoint] = useState<UserPoint | null>(null);
    const [pointHistory, setPointHistory] = useState<PointHistory[]>([]);
    const [activityLoading, setActivityLoading] = useState(false);

    // 추가/수정 다이얼로그 상태
    const [openEditDialog, setOpenEditDialog] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [formData, setFormData] = useState<Partial<User>>({
        username: '',
        email: '',
        authProvider: 'email',
        disabilityType: 'none',
        isActive: true,
    });

    useEffect(() => {
        fetchUsers();
    }, []);

    const fetchUsers = async () => {
        try {
            setLoading(true);
            const data = await getUsers();
            setUsers(data);
        } catch (error) {
            console.error('회원 목록 조회 오류:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleToggleStatus = async (user: User) => {
        const newStatus = !user.isActive;
        const confirmMessage = newStatus
            ? `[${user.username}] 회원을 활성화하시겠습니까?`
            : `[${user.username}] 회원을 정지하시겠습니까? 서비스 이용이 불가능해집니다.`;

        if (window.confirm(confirmMessage)) {
            try {
                await updateUser(user.userId, { isActive: newStatus });
                fetchUsers(); // 목록 새로고침
                if (selectedUser?.userId === user.userId) {
                    setSelectedUser({ ...user, isActive: newStatus });
                }
            } catch (error) {
                console.error('회원 상태 변경 오류:', error);
                alert('상태 변경 중 오류가 발생했습니다.');
            }
        }
    };

    const handleOpenDetail = async (user: User) => {
        setSelectedUser(user);
        setTabValue(0);
        setOpenDetail(true);

        // 탭0(정보) 외에 데이터 미리 로드 (또는 탭 전환 시 로드)
        fetchActivityData(user.userId);
    };

    const fetchActivityData = async (userId: string) => {
        try {
            setActivityLoading(true);
            const [favs, history, points, pHistory] = await Promise.all([
                getUserFavorites(userId),
                getUserDownloadHistory(userId),
                getUserPoints(userId),
                getPointHistory(userId)
            ]);
            setFavorites(favs);
            setDownloadHistory(history);
            setUserPoint(points);
            setPointHistory(pHistory);
        } catch (error) {
            console.error('활동 데이터 조회 오류:', error);
        } finally {
            setActivityLoading(false);
        }
    };

    const handleTabChange = (_: React.SyntheticEvent, newValue: number) => {
        setTabValue(newValue);
    };

    const handleOpenAdd = () => {
        setIsEditing(false);
        setFormData({
            username: '',
            email: '',
            authProvider: 'email',
            disabilityType: 'none',
            isActive: true,
        });
        setOpenEditDialog(true);
    };

    const handleOpenEdit = (user: User) => {
        setIsEditing(true);
        setSelectedUser(user);
        setFormData({
            username: user.username,
            email: user.email || '',
            authProvider: user.authProvider,
            disabilityType: user.disabilityType || 'none',
            isActive: user.isActive,
        });
        setOpenEditDialog(true);
    };

    const handleCloseEditDialog = () => {
        setOpenEditDialog(false);
    };

    const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | { name?: string; value: unknown }>) => {
        const { name, value, checked, type } = e.target as any;
        setFormData((prev) => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value,
        }));
    };

    const handleSubmit = async () => {
        try {
            if (isEditing && selectedUser) {
                await updateUser(selectedUser.userId, formData);
                alert('회원 정보가 수정되었습니다.');
            } else {
                await addUser(formData as Omit<User, 'userId' | 'createdAt' | 'updatedAt'>);
                alert('새 회원이 등록되었습니다.');
            }
            handleCloseEditDialog();
            fetchUsers();
        } catch (error) {
            console.error('회원 저장 오류:', error);
            alert('저장 중 오류가 발생했습니다.');
        }
    };

    const handleDeleteUser = async (user: User) => {
        if (window.confirm(`[${user.username}] 회원을 영구 삭제하시겠습니까? 관련 데이터는 복구할 수 없습니다.`)) {
            try {
                await deleteUser(user.userId);
                alert('회원이 삭제되었습니다.');
                fetchUsers();
                if (selectedUser?.userId === user.userId) setOpenDetail(false);
            } catch (error) {
                console.error('회원 삭제 오류:', error);
                alert('삭제 중 오류가 발생했습니다.');
            }
        }
    };

    const handleCloseDetail = () => {
        setOpenDetail(false);
    };

    const filteredUsers = users.filter(
        (user) =>
            user.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            user.username.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const getAuthProviderLabel = (provider: string) => {
        const labels: Record<string, string> = {
            email: '이메일',
            kakao: '카카오',
            naver: '네이버',
            google: '구글',
            apple: '애플',
        };
        return labels[provider] || provider;
    };

    const getDisabilityTypeLabel = (type?: string) => {
        const labels: Record<string, string> = {
            visual: '시각',
            hearing: '청각',
            none: '없음',
        };
        return type ? labels[type] || type : '-';
    };

    return (
        <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Typography variant="h4" fontWeight="bold">
                    회원 관리
                </Typography>
                <Button variant="contained" startIcon={<AddIcon />} onClick={handleOpenAdd}>
                    회원 추가
                </Button>
            </Box>

            <Paper sx={{ p: 2, mb: 2 }}>
                <TextField
                    fullWidth
                    placeholder="이메일 또는 이름 검색..."
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
                                <TableCell>이메일</TableCell>
                                <TableCell>이름</TableCell>
                                <TableCell>가입 방법</TableCell>
                                <TableCell>장애 유형</TableCell>
                                <TableCell>가입일</TableCell>
                                <TableCell>상태</TableCell>
                                <TableCell align="center">액션</TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {filteredUsers.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={7} align="center">
                                        <Typography variant="body2" color="text.secondary">
                                            회원이 없습니다
                                        </Typography>
                                    </TableCell>
                                </TableRow>
                            ) : (
                                filteredUsers.map((user) => (
                                    <TableRow key={user.userId} hover>
                                        <TableCell>{user.email || '-'}</TableCell>
                                        <TableCell>{user.username}</TableCell>
                                        <TableCell>
                                            <Chip label={getAuthProviderLabel(user.authProvider)} size="small" />
                                        </TableCell>
                                        <TableCell>{getDisabilityTypeLabel(user.disabilityType)}</TableCell>
                                        <TableCell>
                                            {user.createdAt ? format(user.createdAt, 'yyyy-MM-dd') : '-'}
                                        </TableCell>
                                        <TableCell>
                                            <FormControlLabel
                                                control={
                                                    <Switch
                                                        size="small"
                                                        checked={user.isActive}
                                                        onChange={() => handleToggleStatus(user)}
                                                        color="success"
                                                    />
                                                }
                                                label={user.isActive ? '활성' : '정지'}
                                                componentsProps={{ typography: { variant: 'caption' } }}
                                            />
                                        </TableCell>
                                        <TableCell align="center">
                                            <IconButton size="small" color="info" onClick={() => handleOpenDetail(user)} title="상세 정보">
                                                <VisibilityIcon fontSize="small" />
                                            </IconButton>
                                            <IconButton size="small" color="primary" onClick={() => handleOpenEdit(user)} title="정보 수정">
                                                <EditIcon fontSize="small" />
                                            </IconButton>
                                            <IconButton size="small" color="error" onClick={() => handleDeleteUser(user)} title="영구 삭제">
                                                <DeleteIcon fontSize="small" />
                                            </IconButton>
                                        </TableCell>
                                    </TableRow>
                                ))
                            )}
                        </TableBody>
                    </Table>
                </TableContainer>
            )}

            {/* 회원 상세 정보 다이얼로그 */}
            <Dialog open={openDetail} onClose={handleCloseDetail} maxWidth="sm" fullWidth>
                <DialogTitle>회원 상세 정보</DialogTitle>
                <DialogContent dividers sx={{ p: 0 }}>
                    <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
                        <Tabs value={tabValue} onChange={handleTabChange} variant="fullWidth">
                            <Tab label="기본 정보" />
                            <Tab label={`찜 목록 (${favorites.length})`} />
                            <Tab label={`다운로드 (${downloadHistory.length})`} />
                            <Tab label="포인트" />
                        </Tabs>
                    </Box>

                    {/* 기본 정보 탭 */}
                    {tabValue === 0 && selectedUser && (
                        <Box sx={{ p: 3 }}>
                            <Grid container spacing={2}>
                                <Grid size={6}>
                                    <Typography variant="caption" color="text.secondary">사용자 이름</Typography>
                                    <Typography variant="body1" fontWeight="bold">{selectedUser.username}</Typography>
                                </Grid>
                                <Grid size={6}>
                                    <Typography variant="caption" color="text.secondary">이메일</Typography>
                                    <Typography variant="body1">{selectedUser.email || '-'}</Typography>
                                </Grid>
                                <Grid size={6}>
                                    <Typography variant="caption" color="text.secondary">가입 방법</Typography>
                                    <Typography variant="body1">{getAuthProviderLabel(selectedUser.authProvider)}</Typography>
                                </Grid>
                                <Grid size={6}>
                                    <Typography variant="caption" color="text.secondary">장애 유형</Typography>
                                    <Typography variant="body1">{getDisabilityTypeLabel(selectedUser.disabilityType)}</Typography>
                                </Grid>
                                <Grid size={12}><Divider sx={{ my: 1 }} /></Grid>
                                <Grid size={6}>
                                    <Typography variant="caption" color="text.secondary">가입일시</Typography>
                                    <Typography variant="body2">{selectedUser.createdAt ? format(selectedUser.createdAt, 'yyyy-MM-dd HH:mm:ss') : '-'}</Typography>
                                </Grid>
                                <Grid size={6}>
                                    <Typography variant="caption" color="text.secondary">계정 상태</Typography>
                                    <Box sx={{ display: 'flex', alignItems: 'center' }}>
                                        <Chip
                                            label={selectedUser.isActive ? '활성 사용 중' : '사용 정지됨'}
                                            color={selectedUser.isActive ? 'success' : 'error'}
                                            size="small"
                                            sx={{ mr: 1 }}
                                        />
                                        <Button size="small" variant="outlined" onClick={() => handleToggleStatus(selectedUser)}>
                                            상태 변경
                                        </Button>
                                    </Box>
                                </Grid>
                            </Grid>
                        </Box>
                    )}

                    {/* 찜 목록 탭 */}
                    {tabValue === 1 && (
                        <Box sx={{ p: 0, maxHeight: 400, overflow: 'auto' }}>
                            {activityLoading ? (
                                <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}><CircularProgress size={24} /></Box>
                            ) : (
                                <List dense>
                                    {favorites.length === 0 ? (
                                        <Box sx={{ p: 4, textAlign: 'center' }}><Typography variant="body2" color="text.secondary">찜한 영화가 없습니다.</Typography></Box>
                                    ) : (
                                        favorites.map((fav, index) => (
                                            <React.Fragment key={fav.favoriteId}>
                                                <ListItem>
                                                    <Box
                                                        component="img"
                                                        src={fav.movie?.posterUrl || 'https://via.placeholder.com/40x60'}
                                                        sx={{ width: 40, height: 60, objectFit: 'cover', borderRadius: 0.5, mr: 2 }}
                                                    />
                                                    <ListItemText
                                                        primary={fav.movie?.title || '알 수 없는 영화'}
                                                        secondary={`찜한 날짜: ${fav.createdAt ? format(fav.createdAt, 'yyyy-MM-dd HH:mm') : '-'}`}
                                                    />
                                                </ListItem>
                                                {index < favorites.length - 1 && <Divider />}
                                            </React.Fragment>
                                        ))
                                    )}
                                </List>
                            )}
                        </Box>
                    )}

                    {/* 포인트 탭 */}
                    {tabValue === 3 && (
                        <Box sx={{ p: 2, maxHeight: 400, overflow: 'auto' }}>
                            {activityLoading ? (
                                <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}><CircularProgress size={24} /></Box>
                            ) : (
                                <Box>
                                    <Grid container spacing={2} sx={{ mb: 3 }}>
                                        <Grid size={4}>
                                            <Paper elevation={0} sx={{ p: 2, bgcolor: 'primary.light', color: 'primary.contrastText', textAlign: 'center' }}>
                                                <Typography variant="caption">현재 잔액</Typography>
                                                <Typography variant="h6">{(userPoint?.totalPoints || 0).toLocaleString()} P</Typography>
                                            </Paper>
                                        </Grid>
                                        <Grid size={4}>
                                            <Paper elevation={0} sx={{ p: 2, bgcolor: 'success.light', color: 'success.contrastText', textAlign: 'center' }}>
                                                <Typography variant="caption">누적 적립</Typography>
                                                <Typography variant="h6">{(userPoint?.earnedPoints || 0).toLocaleString()} P</Typography>
                                            </Paper>
                                        </Grid>
                                        <Grid size={4}>
                                            <Paper elevation={0} sx={{ p: 2, bgcolor: 'info.light', color: 'info.contrastText', textAlign: 'center' }}>
                                                <Typography variant="caption">누적 사용</Typography>
                                                <Typography variant="h6">{(userPoint?.usedPoints || 0).toLocaleString()} P</Typography>
                                            </Paper>
                                        </Grid>
                                    </Grid>

                                    <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 'bold' }}>상세 내역</Typography>
                                    <TableContainer component={Paper} elevation={0} variant="outlined">
                                        <Table size="small">
                                            <TableHead>
                                                <TableRow sx={{ bgcolor: 'action.disabledBackground' }}>
                                                    <TableCell sx={{ fontSize: '0.75rem' }}>날짜</TableCell>
                                                    <TableCell sx={{ fontSize: '0.75rem' }}>구분</TableCell>
                                                    <TableCell sx={{ fontSize: '0.75rem' }} align="right">금액</TableCell>
                                                    <TableCell sx={{ fontSize: '0.75rem' }} align="right">잔액</TableCell>
                                                </TableRow>
                                            </TableHead>
                                            <TableBody>
                                                {pointHistory.length === 0 ? (
                                                    <TableRow>
                                                        <TableCell colSpan={4} align="center">이력이 없습니다.</TableCell>
                                                    </TableRow>
                                                ) : (
                                                    pointHistory.map((history) => (
                                                        <TableRow key={history.historyId}>
                                                            <TableCell sx={{ fontSize: '0.75rem' }}>{history.createdAt ? format(history.createdAt, 'MM-dd HH:mm') : '-'}</TableCell>
                                                            <TableCell sx={{ fontSize: '0.75rem' }}>{history.reason}</TableCell>
                                                            <TableCell sx={{ fontSize: '0.75rem', color: history.pointType === 'earn' ? 'success.main' : 'error.main' }} align="right">
                                                                {history.pointType === 'earn' ? '+' : '-'}{history.points.toLocaleString()}
                                                            </TableCell>
                                                            <TableCell sx={{ fontSize: '0.75rem' }} align="right">{history.balanceAfter.toLocaleString()}</TableCell>
                                                        </TableRow>
                                                    ))
                                                )}
                                            </TableBody>
                                        </Table>
                                    </TableContainer>
                                </Box>
                            )}
                        </Box>
                    )}
                </DialogContent>
                <DialogActions>
                    <Button onClick={handleCloseDetail} color="primary">닫기</Button>
                </DialogActions>
            </Dialog>

            {/* 회원 추가/수정 다이얼로그 */}
            <Dialog open={openEditDialog} onClose={handleCloseEditDialog} maxWidth="xs" fullWidth>
                <DialogTitle>{isEditing ? '회원 정보 수정' : '신규 회원 등록'}</DialogTitle>
                <DialogContent dividers>
                    <Grid container spacing={2} sx={{ mt: 0.5 }}>
                        <Grid size={12}>
                            <TextField
                                fullWidth
                                label="사용자 이름*"
                                name="username"
                                value={formData.username}
                                onChange={handleInputChange}
                                required
                            />
                        </Grid>
                        <Grid size={12}>
                            <TextField
                                fullWidth
                                label="이메일"
                                name="email"
                                type="email"
                                value={formData.email}
                                onChange={handleInputChange}
                            />
                        </Grid>
                        <Grid size={12}>
                            <TextField
                                fullWidth
                                select
                                label="가입 방법"
                                name="authProvider"
                                value={formData.authProvider}
                                onChange={handleInputChange}
                                SelectProps={{ native: true }}
                            >
                                <option value="email">이메일</option>
                                <option value="kakao">카카오</option>
                                <option value="naver">네이버</option>
                                <option value="google">구글</option>
                                <option value="apple">애플</option>
                            </TextField>
                        </Grid>
                        <Grid size={12}>
                            <TextField
                                fullWidth
                                select
                                label="장애 유형"
                                name="disabilityType"
                                value={formData.disabilityType}
                                onChange={handleInputChange}
                                SelectProps={{ native: true }}
                            >
                                <option value="none">없음</option>
                                <option value="visual">시각</option>
                                <option value="hearing">청각</option>
                            </TextField>
                        </Grid>
                        <Grid size={12}>
                            <FormControlLabel
                                control={
                                    <Switch
                                        name="isActive"
                                        checked={formData.isActive}
                                        onChange={handleInputChange}
                                        color="success"
                                    />
                                }
                                label={formData.isActive ? '계정 활성 상태' : '계정 정지 상태'}
                            />
                        </Grid>
                    </Grid>
                </DialogContent>
                <DialogActions>
                    <Button onClick={handleCloseEditDialog}>취소</Button>
                    <Button onClick={handleSubmit} variant="contained" color="primary">저장</Button>
                </DialogActions>
            </Dialog>
        </Box>
    );
};

export default Users;
