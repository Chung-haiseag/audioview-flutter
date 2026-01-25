'use client';

import { Notification, rem } from '@mantine/core';
import { IconWifiOff } from '@tabler/icons-react';
import { useNetwork } from '@mantine/hooks';
import { useEffect, useState } from 'react';

export function OfflineNotification() {
    const network = useNetwork();
    const [show, setShow] = useState(false);

    useEffect(() => {
        if (!network.online) {
            setShow(true);
        } else {
            setShow(false);
        }
    }, [network.online]);

    if (!show) return null;

    return (
        <div style={{ position: 'fixed', bottom: 20, right: 20, zIndex: 9999 }}>
            <Notification
                icon={<IconWifiOff size={rem(20)} />}
                color="red"
                title="오프라인 상태입니다"
                withCloseButton={false}
            >
                인터넷 연결을 확인해주세요. 일부 기능이 제한될 수 있습니다.
            </Notification>
        </div>
    );
}
