// TypeScript 타입 정의

export interface Genre {
    genreId: string;
    genreName: string;
    genreDescription?: string;
    createdAt: Date;
    updatedAt: Date;
}

export interface ProductionCompany {
    companyId: string;
    companyName: string;
    country?: string;
    establishedYear?: number;
    companyWebsite?: string;
    createdAt: Date;
    updatedAt: Date;
}

export interface Movie {
    movieId: string;
    title: string;
    releaseDate: Date;
    directorName?: string;
    runningTime?: number;
    synopsis?: string;
    posterUrl?: string;
    rating?: string;
    hasAudioCommentary: boolean;
    hasClosedCaption: boolean;
    audioCommentaryFile?: string;
    closedCaptionFile?: string;
    isLatest: boolean;
    isPopular: boolean;
    genreId?: string;
    productionCountry?: string;
    searchKeywords?: string[];
    createdAt: Date;
    updatedAt: Date;
}

export interface User {
    userId: string;
    email?: string;
    username: string;
    phone?: string;
    profileImage?: string;
    authProvider: 'email' | 'kakao' | 'naver' | 'google' | 'apple';
    socialId?: string;
    disabilityType?: 'visual' | 'hearing' | 'none';
    isActive: boolean;
    lastLoginAt?: Date;
    createdAt: Date;
    updatedAt: Date;
}

export interface FeaturedList {
    listId: string;
    listName: string;
    listDescription?: string;
    maxItems?: number;
    isActive: boolean;
    displayOrder: number;
    createdAt: Date;
}

export interface FeaturedMovie {
    featuredId: string;
    listId: string;
    movieId: string;
    displayOrder: number;
    featuredDate: Date;
    createdAt: Date;
}

export interface UserPoint {
    userId: string;
    totalPoints: number;
    earnedPoints: number;
    usedPoints: number;
    createdAt: Date;
    updatedAt: Date;
}

export interface PointHistory {
    historyId: string;
    userId: string;
    pointType: 'earn' | 'use';
    points: number;
    reason: string;
    balanceAfter: number;
    createdAt: Date;
}

export interface Notice {
    noticeId: string;
    title: string;
    content: string;
    noticeType: 'general' | 'update' | 'event' | 'important';
    isImportant: boolean;
    isPushSent: boolean;
    pushTitle?: string;
    pushMessage?: string;
    thumbnailUrl?: string;
    linkUrl?: string;
    movieId?: string;
    viewCount: number;
    publishedAt?: Date;
    expiresAt?: Date;
    createdBy?: string;
    createdAt: Date;
    updatedAt: Date;
}

export interface UserFavorite {
    favoriteId: string;
    userId: string;
    movieId: string;
    movie?: Movie;
    createdAt: Date;
}

export interface UserDownloadHistory {
    downloadId: string;
    userId: string;
    movieId: string;
    movie?: Movie;
    downloadedAt: Date;
}

export interface DashboardStats {
    totalMovies: number;
    totalUsers: number;
    newUsersThisMonth: number;
    totalDownloads: number;
}

export interface AuthUser {
    uid: string;
    email: string | null;
    displayName: string | null;
    isAdmin: boolean;
}
