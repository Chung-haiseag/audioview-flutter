import React, { useState } from 'react';
import {
    Box,
    Container,
    Paper,
    TextField,
    Button,
    Typography,
    Alert,
    CircularProgress,
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const Login: React.FC = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const { signIn } = useAuth();
    const navigate = useNavigate();

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError('');
        setLoading(true);

        try {
            await signIn(email, password);
            navigate('/');
        } catch (err: any) {
            console.error('로그인 오류:', err);
            if (err.code === 'auth/invalid-credential') {
                setError('이메일 또는 비밀번호가 올바르지 않습니다.');
            } else if (err.message === '관리자 권한이 없습니다.') {
                setError('관리자 권한이 없습니다.');
            } else {
                setError('로그인 중 오류가 발생했습니다.');
            }
        } finally {
            setLoading(false);
        }
    };

    return (
        <Box
            sx={{
                minHeight: '100vh',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
            }}
        >
            <Container maxWidth="sm">
                <Paper elevation={3} sx={{ p: 4 }}>
                    <Typography variant="h4" component="h1" gutterBottom align="center" fontWeight="bold">
                        관리자 로그인
                    </Typography>
                    <Typography variant="body2" color="text.secondary" align="center" sx={{ mb: 3 }}>
                        베리어프리 영화 서비스 관리자 대시보드
                    </Typography>

                    {error && (
                        <Alert severity="error" sx={{ mb: 2 }}>
                            {error}
                        </Alert>
                    )}

                    <form onSubmit={handleSubmit}>
                        <TextField
                            fullWidth
                            label="이메일"
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            margin="normal"
                            required
                            autoFocus
                        />
                        <TextField
                            fullWidth
                            label="비밀번호"
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            margin="normal"
                            required
                        />
                        <Button
                            fullWidth
                            type="submit"
                            variant="contained"
                            size="large"
                            disabled={loading}
                            sx={{ mt: 3, mb: 2, height: 48 }}
                        >
                            {loading ? <CircularProgress size={24} /> : '로그인'}
                        </Button>
                    </form>

                    <Typography variant="caption" color="text.secondary" align="center" display="block">
                        관리자 계정이 필요합니다
                    </Typography>
                </Paper>
            </Container>
        </Box>
    );
};

export default Login;
