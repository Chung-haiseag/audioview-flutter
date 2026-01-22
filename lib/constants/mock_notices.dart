import '../models/notice.dart';

List<Notice> mockNotices = [
  Notice(
    id: '1',
    title: '[공지] 시스템 점검 안내 (1/24)',
    content: """안녕하세요, AudioView 팀입니다.

더 나은 서비스 제공을 위해 아래와 같이 시스템 점검이 진행될 예정입니다.

■ 점검 일시
2026년 1월 24일(토) 02:00 ~ 04:00 (2시간)

■ 점검 내용
- 서버 안정화 및 보안 업데이트
- 데이터베이스 최적화

점검 시간 동안에는 앱 이용이 일시적으로 제한될 수 있습니다.
이용에 불편을 드려 죄송합니다.

감사합니다.""",
    date: DateTime(2026, 1, 20),
    type: NoticeType.notice,
    isNew: true,
  ),
  Notice(
    id: '2',
    title: '[안내] 개인정보 처리방침 변경 안내',
    content: """안녕하세요.

개인정보 보호법 개정에 따라 개인정보 처리방침이 일부 변경됩니다.
자세한 내용은 홈페이지 하단의 '개인정보 처리방침'을 참고해 주시기 바랍니다.

시행일: 2026년 2월 1일""",
    date: DateTime(2026, 1, 15),
    type: NoticeType.notice,
  ),
  Notice(
    id: '3',
    title: '[이벤트] 신규 가입 회원 웰컴 선물 증정!',
    content: """AudioView에 오신 것을 환영합니다! 🎉

신규 가입하신 모든 분들께 영화 1편 무료 감상 쿠폰을 드립니다.
쿠폰함에서 확인해보세요!

이벤트 기간: 2026.1.1 ~ 2026.1.31""",
    date: DateTime(2026, 1, 22),
    type: NoticeType.event,
    isNew: true,
  ),
  Notice(
    id: '4',
    title: '[이벤트] 친구 초대하고 포인트 받자',
    content: """친구를 초대하면 나도 친구도 3,000 포인트!
    
최대 10명까지 초대 가능합니다.
지금 바로 친구에게 AudioView를 소개해주세요.""",
    date: DateTime(2026, 1, 10),
    type: NoticeType.event,
  ),
  Notice(
    id: '5',
    title: '[업데이트] ver 1.2.0 기능 추가 안내',
    content: "음성 검색 기능이 추가되었습니다. 이제 마이크 버튼을 눌러 말로 영화를 검색해보세요!",
    date: DateTime(2026, 1, 18),
    type: NoticeType.notice,
  ),
];
