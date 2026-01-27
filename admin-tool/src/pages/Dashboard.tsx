import React, { useEffect, useState } from 'react';
import {
    Box,
    Grid,
    Card,
    CardContent,
    Typography,
    Paper,
} from '@mui/material';
import {
    Movie as MovieIcon,
    People as PeopleIcon,
    Download as DownloadIcon,
    TrendingUp as TrendingUpIcon,
} from '@mui/icons-material';
import { getMovies } from '../services/movieService';
import { getUserStats } from '../services/userService';

interface StatCardProps {
    title: string;
    value: number | string;
    icon: React.ReactNode;
    color: string;
}

const StatCard: React.FC<StatCardProps> = ({ title, value, icon, color }) => (
    <Card>
        <CardContent>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <Box>
                    <Typography color="text.secondary" variant="body2" gutterBottom>
                        {title}
                    </Typography>
                    <Typography variant="h4" fontWeight="bold">
                        {value}
                    </Typography>
                </Box>
                <Box
                    sx={{
                        bgcolor: color,
                        borderRadius: 2,
                        p: 1.5,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                    }}
                >
                    {icon}
                </Box>
            </Box>
        </CardContent>
    </Card>
);

const Dashboard: React.FC = () => {
    const [stats, setStats] = useState({
        totalMovies: 0,
        totalUsers: 0,
        newUsersThisMonth: 0,
        totalDownloads: 0,
    });

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const [movies, userStats] = await Promise.all([
                    getMovies(),
                    getUserStats(),
                ]);

                setStats({
                    totalMovies: movies.length,
                    totalUsers: userStats.totalUsers,
                    newUsersThisMonth: userStats.newUsersThisMonth,
                    totalDownloads: 0, // TODO: 다운로드 통계 구현
                });
            } catch (error) {
                console.error('통계 조회 오류:', error);
            }
        };

        fetchStats();
    }, []);

    return (
        <Box>
            <Typography variant="h4" gutterBottom fontWeight="bold">
                대시보드
            </Typography>
            <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
                베리어프리 영화 서비스 관리자 대시보드에 오신 것을 환영합니다
            </Typography>

            <Grid container spacing={3}>
                <Grid size={{ xs: 12, sm: 6, md: 3 }}>
                    <StatCard
                        title="총 영화 수"
                        value={stats.totalMovies}
                        icon={<MovieIcon sx={{ color: 'white', fontSize: 32 }} />}
                        color="primary.main"
                    />
                </Grid>
                <Grid size={{ xs: 12, sm: 6, md: 3 }}>
                    <StatCard
                        title="총 회원 수"
                        value={stats.totalUsers}
                        icon={<PeopleIcon sx={{ color: 'white', fontSize: 32 }} />}
                        color="success.main"
                    />
                </Grid>
                <Grid size={{ xs: 12, sm: 6, md: 3 }}>
                    <StatCard
                        title="이번 달 신규 회원"
                        value={stats.newUsersThisMonth}
                        icon={<TrendingUpIcon sx={{ color: 'white', fontSize: 32 }} />}
                        color="warning.main"
                    />
                </Grid>
                <Grid size={{ xs: 12, sm: 6, md: 3 }}>
                    <StatCard
                        title="총 다운로드"
                        value={stats.totalDownloads}
                        icon={<DownloadIcon sx={{ color: 'white', fontSize: 32 }} />}
                        color="info.main"
                    />
                </Grid>

                <Grid size={12}>
                    <Paper sx={{ p: 3 }}>
                        <Typography variant="h6" gutterBottom fontWeight="bold">
                            최근 활동
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                            최근 활동 내역이 여기에 표시됩니다.
                        </Typography>
                    </Paper>
                </Grid>
            </Grid>
        </Box>
    );
};

export default Dashboard;
