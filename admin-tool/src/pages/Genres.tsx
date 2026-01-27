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
    TextField,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    CircularProgress,
    Grid,
} from '@mui/material';
import {
    Add as AddIcon,
    Edit as EditIcon,
    Delete as DeleteIcon,
} from '@mui/icons-material';
import { getGenres, addGenre, updateGenre, deleteGenre, Genre } from '../services/genreService';

const Genres: React.FC = () => {
    const [genres, setGenres] = useState<Genre[]>([]);
    const [loading, setLoading] = useState(true);
    const [openDialog, setOpenDialog] = useState(false);
    const [editingGenre, setEditingGenre] = useState<Genre | null>(null);
    const [formData, setFormData] = useState<Partial<Genre>>({
        genreName: '',
        genreDescription: '',
    });

    useEffect(() => {
        fetchGenres();
    }, []);

    const fetchGenres = async () => {
        try {
            setLoading(true);
            const data = await getGenres();
            setGenres(data);
        } catch (error) {
            console.error('장르 목록 조회 오류:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleOpenAdd = () => {
        setEditingGenre(null);
        setFormData({ genreName: '', genreDescription: '' });
        setOpenDialog(true);
    };

    const handleOpenEdit = (genre: Genre) => {
        setEditingGenre(genre);
        setFormData({ ...genre });
        setOpenDialog(true);
    };

    const handleCloseDialog = () => setOpenDialog(false);

    const handleSubmit = async () => {
        if (!formData.genreName) {
            alert('장르명을 입력해 주세요.');
            return;
        }

        try {
            if (editingGenre) {
                await updateGenre(editingGenre.genreId, formData);
            } else {
                await addGenre(formData as Omit<Genre, 'genreId'>);
            }
            handleCloseDialog();
            fetchGenres();
        } catch (error) {
            console.error('장르 저장 오류:', error);
            alert('저장 중 오류가 발생했습니다.');
        }
    };

    const handleDelete = async (genreId: string) => {
        if (window.confirm('이 장르를 삭제하시겠습니까? 연결된 영화 정보에 영향을 줄 수 있습니다.')) {
            try {
                await deleteGenre(genreId);
                fetchGenres();
            } catch (error) {
                console.error('장르 삭제 오류:', error);
                alert('삭제 중 오류가 발생했습니다.');
            }
        }
    };

    return (
        <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Typography variant="h4" fontWeight="bold">장르 관리</Typography>
                <Button variant="contained" startIcon={<AddIcon />} onClick={handleOpenAdd}>장르 추가</Button>
            </Box>

            {loading ? (
                <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}><CircularProgress /></Box>
            ) : (
                <TableContainer component={Paper}>
                    <Table>
                        <TableHead>
                            <TableRow>
                                <TableCell>장르명</TableCell>
                                <TableCell>설명</TableCell>
                                <TableCell align="center">액션</TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {genres.length === 0 ? (
                                <TableRow><TableCell colSpan={3} align="center">등록된 장르가 없습니다.</TableCell></TableRow>
                            ) : (
                                genres.map((genre) => (
                                    <TableRow key={genre.genreId} hover>
                                        <TableCell sx={{ fontWeight: 'bold' }}>{genre.genreName}</TableCell>
                                        <TableCell>{genre.genreDescription || '-'}</TableCell>
                                        <TableCell align="center">
                                            <IconButton size="small" color="primary" onClick={() => handleOpenEdit(genre)}>
                                                <EditIcon />
                                            </IconButton>
                                            <IconButton size="small" color="error" onClick={() => handleDelete(genre.genreId)}>
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

            <Dialog open={openDialog} onClose={handleCloseDialog} fullWidth maxWidth="xs">
                <DialogTitle>{editingGenre ? '장르 수정' : '새 장르 등록'}</DialogTitle>
                <DialogContent dividers>
                    <Grid container spacing={2} sx={{ mt: 0.5 }}>
                        <Grid size={12}>
                            <TextField
                                fullWidth
                                label="장르명*"
                                value={formData.genreName}
                                onChange={(e) => setFormData(p => ({ ...p, genreName: e.target.value }))}
                            />
                        </Grid>
                        <Grid size={12}>
                            <TextField
                                fullWidth
                                label="설명"
                                multiline
                                rows={3}
                                value={formData.genreDescription}
                                onChange={(e) => setFormData(p => ({ ...p, genreDescription: e.target.value }))}
                            />
                        </Grid>
                    </Grid>
                </DialogContent>
                <DialogActions>
                    <Button onClick={handleCloseDialog}>취소</Button>
                    <Button onClick={handleSubmit} variant="contained" color="primary">저장</Button>
                </DialogActions>
            </Dialog>
        </Box>
    );
};

export default Genres;
