# Aether 🌌

> *"당신의 소망을 저 너머 허공으로."*

[![Download for macOS](https://img.shields.io/badge/Download-Aether_for_macOS-blue?style=for-the-badge&logo=apple)](https://github.com/damagethundercat/Aether/raw/main/Aether_Installer.dmg)

**Aether** (구 Wishcaster)는 마음에 담신 생각, 소망, 혹은 답답함을 적어 우주로 날려보내는 macOS 메뉴바 앱입니다.

**Native Swift (AppKit)**의 견고한 시스템 통합과 **p5.js**의 아름다운 파티클 시각 효과를 결합했습니다.

![Aether Screenshot](https://via.placeholder.com/800x450?text=Aether+Screenshot)

## ✨ 주요 기능

*   **메뉴바 앱**: 독(Dock)을 차지하지 않고 언제든 메뉴바에서 불러올 수 있습니다.
*   **아름다운 시각 효과**: 텍스트가 별가루가 되어 흩어지는 모습을 p5.js 파티클 엔진으로 감상하세요.
*   **촉각 피드백**: 엔터를 누르는 순간 포스 터치 트랙패드의 진동을 통해 전송 감각을 느낄 수 있습니다.
*   **실제 전송 구현**: 실제로 입력한 텍스트를 UDP 패킷으로 변환하여 로컬 네트워크(`255.255.255.255`)로 쏘아 보냅니다. (네트워크 모니터에서 확인 가능!)
*   **연하장 기능**: 앱 정보 창에 개발자의 연하장(편지) 기능을 내장하고 있습니다.

## 📦 설치 방법

이 앱은 Mac App Store가 아닌 수동으로 배포되므로, 최초 실행 시 권한 허용이 필요합니다.

1.  Releases 페이지에서 `Aether.dmg`를 다운로드합니다.
2.  DMG 파일을 열고 **Aether**를 **Applications (응용 프로그램)** 폴더로 드래그합니다.
3.  Aether 아이콘을 **마우스 우클릭(또는 Control+클릭)**한 뒤 **'열기'**를 선택합니다.
4.  경고창이 뜨면 **'열기'** 버튼을 누릅니다. (이 과정은 최초 1회만 필요합니다.)

## 🛠 개발자를 위한 가이드

Aether를 수정하거나 기여하고 싶으신가요? **Xcode 프로젝트 파일 없이도** 터미널만으로 빌드할 수 있도록 설계했습니다.

### 필수 조건
*   macOS 11.0 이상
*   Swift 5.x (Xcode Command Line Tools 설치 필요)

### 빌드하는 법

1.  **저장소 복제**
    ```bash
    git clone https://github.com/damagethundercat/Aether.git
    cd Aether/WishcasterSwift
    ```

2.  **빌드**
    간단한 쉘 스크립트로 컴파일과 패키징을 한 번에 처리합니다.
    ```bash
    ./build_app.sh
    ```
    완료되면 현재 폴더에 `Aether.app`이 생성됩니다.

3.  **실행**
    ```bash
    open Aether.app
    ```

4.  **패키징 (선택 사항)**
    배포용 DMG 파일을 만들려면:
    ```bash
    ./create_installer.sh
    ```
    이 스크립트는 `Installer/` 폴더의 배경 이미지를 사용하여 DMG를 생성합니다. (참고: `create-dmg-repo`는 DMG 생성을 도와주는 외부 도구입니다)

## 🏗 기술 스택

*   **Swift (AppKit)**: 메인 앱 로직, 창 관리, 메뉴바 연동, UDP 네트워킹.
*   **WKWebView**: Swift와 JavaScript(p5.js)를 연결하는 브릿지.
*   **p5.js**: 은하수 배경과 텍스트 폭발 파티클 렌더링.

## 📂 프로젝트 구조

```
Aether/
├── Sources/
│   ├── main.swift             # 진입점
│   ├── AppDelegate.swift      # 앱 수명주기 & 메뉴바 아이콘
│   ├── WebViewController.swift# WebView & 입력 처리
│   ├── SignalTransmitter.swift# UDP 네트워크 로직
│   └── AboutWindowController.swift # "About" 창 (연하장)
├── Resources/                 # HTML, JS, 이미지 리소스
├── Installer/                 # DMG 배경 이미지 및 생성 스크립트
├── create-dmg-repo/           # DMG 생성 도구 (Submodule)
├── build_app.sh               # 앱 빌드 스크립트
└── create_installer.sh        # DMG 패키징 스크립트
```

## 📝 라이선스

MIT 라이선스로 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참고하세요.
