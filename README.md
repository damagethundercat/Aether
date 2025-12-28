# Aether 🌌

> *"당신의 소망을 저 너머 허공으로."*

[![Download for macOS](https://img.shields.io/badge/Download-Aether_for_macOS-blue?style=for-the-badge&logo=apple)](https://github.com/damagethundercat/Aether/raw/main/Aether_Installer.dmg)

**Aether**는 마음에 담긴 생각, 소망, 혹은 털어놓고 싶은 답답함을 적어 디지털 우주로 날려보내는 macOS 메뉴바 앱입니다.

복잡한 독(Dock)을 차지하지 않습니다. 언제든 메뉴바에서 조용히 불러내어 당신의 생각을 적으세요. 엔터 키를 누르면 텍스트는 별가루가 되어 흩어지고, 실제 데이터 패킷이 되어 텅 빈 네트워크 허공으로 사라집니다.

![Aether Preview](https://via.placeholder.com/800x450?text=Insert+GIF+Here)
*(여기에 정적인 스크린샷보다는 파티클이 터지는 GIF를 넣는 것을 추천합니다)*

## ✨ 주요 경험

* **Silent Companion**: 작업 흐름을 방해하지 않고 메뉴바에 조용히 상주합니다.
* **Visual Delight**: 텍스트가 입력되는 순간부터 별가루가 되어 흩어지는 순간까지, 아름다운 파티클 인터랙션을 감상하세요.
* **Tactile Feedback**: 텍스트를 전송하는 순간, 트랙패드의 미세한 진동(Haptic)을 통해 무언가가 손끝에서 떠나가는 감각을 전달합니다.
* **Into the Void**: 단순한 시각 효과가 아닙니다. 당신이 쓴 글은 실제로 암호화된 신호가 되어 로컬 네트워크의 허공(`255.255.255.255`)으로 영원히 방출됩니다.
* **Letter from Dev**: 앱 정보 창에는 개발자가 보내는 작은 연하장이 숨겨져 있습니다.

## 📦 설치 및 실행 방법

Aether는 App Store를 거치지 않은 인디 앱입니다. 최초 실행 시 macOS 보안 설정에 대한 허용이 필요합니다.

1.  위의 **Download** 버튼을 눌러 `Aether.dmg`를 받습니다.
2.  파일을 열고 **Aether** 아이콘을 **Applications** 폴더로 드래그합니다.
3.  **[중요]** 앱을 처음 실행할 때, 아이콘을 **마우스 우클릭(또는 Control+클릭)**한 뒤 **'열기'**를 눌러주세요.
4.  경고창이 뜨면 **'열기'**를 한 번 더 클릭합니다. (이 과정은 처음에만 필요합니다.)

---

<details>
<summary>🛠 <b>개발자 및 기여자를 위한 정보 (Click)</b></summary>

### Tech Stack
* **Swift (AppKit)**: Native macOS Experience & Networking
* **p5.js & WKWebView**: Particle System & Visuals

### How to Build
Xcode 프로젝트 파일 없이 터미널만으로 빌드가 가능합니다.

**필수 조건**: macOS 11.0+, Swift 5.x (Xcode Command Line Tools)

1.  **Clone**
    ```bash
    git clone [https://github.com/damagethundercat/Aether.git](https://github.com/damagethundercat/Aether.git)
    cd Aether/WishcasterSwift
    ```

2.  **Build & Run**
    ```bash
    ./build_app.sh   # 빌드 (Aether.app 생성)
    open Aether.app  # 실행
    ```

</details>

## 📝 라이선스
MIT License. 자유롭게 수정하고 사용하세요.
