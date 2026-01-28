import React, { useState, useEffect } from 'react';
import {
    TextField,
    Autocomplete,
    CircularProgress,
    Box,
    Typography,
} from '@mui/material';
import { getMovies } from '../services/movieService';
import { Movie } from '../types';

interface MovieSelectorProps {
    value?: string;
    onChange: (movieId?: string) => void;
}

const MovieSelector: React.FC<MovieSelectorProps> = ({ value, onChange }) => {
    const [open, setOpen] = useState(false);
    const [options, setOptions] = useState<Movie[]>([]);
    const [loading, setLoading] = useState(false);
    const [selectedMovie, setSelectedMovie] = useState<Movie | null>(null);

    useEffect(() => {
        let active = true;

        if (!loading) {
            return undefined;
        }

        (async () => {
            try {
                const movies = await getMovies();
                if (active) {
                    setOptions(movies);
                }
            } catch (error) {
                console.error('Failed to fetch movies:', error);
            } finally {
                if (active) {
                    setLoading(false);
                }
            }
        })();

        return () => {
            active = false;
        };
    }, [loading]);

    useEffect(() => {
        if (!open) {
            setOptions([]);
        } else {
            setLoading(true);
        }
    }, [open]);

    useEffect(() => {
        if (value && options.length > 0) {
            const movie = options.find((m) => m.movieId === value);
            if (movie) setSelectedMovie(movie);
        } else if (!value) {
            setSelectedMovie(null);
        }
    }, [value, options]);

    return (
        <Autocomplete
            id="movie-selector"
            open={open}
            onOpen={() => setOpen(true)}
            onClose={() => setOpen(false)}
            isOptionEqualToValue={(option, val) => option.movieId === val.movieId}
            getOptionLabel={(option) => option.title}
            options={options}
            loading={loading}
            value={selectedMovie}
            onChange={(_event, newValue) => {
                setSelectedMovie(newValue);
                onChange(newValue?.movieId);
            }}
            renderInput={(params) => (
                <TextField
                    {...params}
                    label="관련 영화 연결 (선택)"
                    placeholder="영화 제목 검색..."
                    InputProps={{
                        ...params.InputProps,
                        endAdornment: (
                            <React.Fragment>
                                {loading ? <CircularProgress color="inherit" size={20} /> : null}
                                {params.InputProps.endAdornment}
                            </React.Fragment>
                        ),
                    }}
                />
            )}
            renderOption={(props, option) => (
                <Box component="li" {...props} key={option.movieId}>
                    <Box sx={{ display: 'flex', alignItems: 'center' }}>
                        {option.posterUrl && (
                            <Box
                                component="img"
                                src={option.posterUrl}
                                sx={{ width: 40, height: 60, mr: 2, borderRadius: 1 }}
                            />
                        )}
                        <Box>
                            <Typography variant="body1">{option.title}</Typography>
                            <Typography variant="caption" color="text.secondary">
                                {option.directorName || '감독 정보 없음'}
                            </Typography>
                        </Box>
                    </Box>
                </Box>
            )}
        />
    );
};

export default MovieSelector;
