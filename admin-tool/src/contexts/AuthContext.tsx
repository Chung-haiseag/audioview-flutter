import React, { createContext, useContext, useState, useEffect, type ReactNode } from 'react';
import { getCurrentUser, checkAdminRole, signIn as authSignIn, signOut as authSignOut } from '../services/authService';
import type { AuthUser } from '../types';

interface AuthContextType {
    user: AuthUser | null;
    loading: boolean;
    signIn: (email: string, password: string) => Promise<void>;
    signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within AuthProvider');
    }
    return context;
};

interface AuthProviderProps {
    children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
    const [user, setUser] = useState<AuthUser | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const initAuth = async () => {
            try {
                const currentUser = await getCurrentUser();
                if (currentUser) {
                    const isAdmin = await checkAdminRole(currentUser);
                    setUser({
                        uid: currentUser.uid,
                        email: currentUser.email,
                        displayName: currentUser.displayName,
                        isAdmin,
                    });
                }
            } catch (error) {
                console.error('인증 초기화 오류:', error);
            } finally {
                setLoading(false);
            }
        };

        initAuth();
    }, []);

    const signIn = async (email: string, password: string) => {
        const firebaseUser = await authSignIn(email, password);
        const isAdmin = await checkAdminRole(firebaseUser);
        setUser({
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName,
            isAdmin,
        });
    };

    const signOut = async () => {
        await authSignOut();
        setUser(null);
    };

    const value = {
        user,
        loading,
        signIn,
        signOut,
    };

    return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
