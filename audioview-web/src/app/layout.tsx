import '@mantine/core/styles.css';
import React from 'react';
import { ColorSchemeScript, MantineProvider } from '@mantine/core';
import { theme } from '../../theme';
import { AppLayout } from '../components/AppLayout';
import { AuthProvider } from '../context/AuthProvider';
import { OfflineNotification } from '../components/OfflineNotification';

export const metadata = {
  title: 'AudioView',
  description: 'Premium Audio Description Service',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <head>
        <ColorSchemeScript defaultColorScheme="dark" />
      </head>
      <body>
        <MantineProvider theme={theme} defaultColorScheme="dark">
          <AuthProvider>
            <AppLayout>
              {children}
            </AppLayout>
            <OfflineNotification />
          </AuthProvider>
        </MantineProvider>
      </body>
    </html>
  );
}
