import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '자주 묻는 질문',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFAQItem(
            '화면해설(AD)이란 무엇인가요?',
            '화면해설(Audio Description)은 시각장애인을 위한 서비스로, 영상의 장면, 인물의 동작, 배경 등을 음성으로 설명해주는 기능입니다. 대사가 없는 장면에서 자동으로 재생됩니다.',
          ),
          _buildFAQItem(
            '문자자막(CC)과 일반 자막의 차이는 무엇인가요?',
            '문자자막(Closed Caption)은 청각장애인을 위한 서비스로, 대사뿐만 아니라 배경음악, 효과음 등 모든 소리 정보를 텍스트로 제공합니다. 일반 자막은 대사만 표시됩니다.',
          ),
          _buildFAQItem(
            '스마트 안경은 어떻게 연동하나요?',
            '설정 메뉴에서 "스마트 안경" 항목을 선택하고, 블루투스를 통해 기기를 페어링하면 자동으로 연동됩니다. 연동 후 영상 시청 시 안경을 통해 화면해설을 들을 수 있습니다.',
          ),
          _buildFAQItem(
            'WiFi 없이도 사용할 수 있나요?',
            '설정에서 "3G/LTE 사용"을 활성화하면 모바일 데이터로도 서비스를 이용할 수 있습니다. 단, 데이터 요금이 발생할 수 있으니 주의하세요.',
          ),
          _buildFAQItem(
            '영화를 다운로드할 수 있나요?',
            '현재는 스트리밍 서비스만 제공하고 있으며, 다운로드 기능은 추후 업데이트 예정입니다.',
          ),
          _buildFAQItem(
            '여러 기기에서 동시에 시청할 수 있나요?',
            '하나의 계정으로 최대 2개의 기기에서 동시에 시청할 수 있습니다. 프리미엄 플랜에서는 최대 4개까지 가능합니다.',
          ),
          _buildFAQItem(
            '자막 크기를 조절할 수 있나요?',
            '설정 메뉴의 "자막 스타일 설정"에서 자막의 크기, 색상, 배경 등을 자유롭게 조절할 수 있습니다.',
          ),
          _buildFAQItem(
            '회원 탈퇴는 어떻게 하나요?',
            '설정 > 계정 관리 > 회원 탈퇴 메뉴에서 탈퇴할 수 있습니다. 탈퇴 시 모든 시청 기록과 개인정보가 삭제됩니다.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.grey,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                answer,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
