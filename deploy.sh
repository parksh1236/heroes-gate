#!/bin/bash
# ============================================
# 영웅문: 화산논검 — GitHub Pages 무료 배포 스크립트
# 사용법: 터미널에서  ./deploy.sh  실행
# (사전 준비: gh auth login 으로 GitHub 로그인 1회)
# ============================================
set -e
export PATH="/opt/homebrew/bin:$PATH"
export GH_CONFIG_DIR="$HOME/.gh-config"   # ~/.config가 root 소유라 우회
cd "$(dirname "$0")"

# 1. GitHub 로그인 확인
if ! gh auth status >/dev/null 2>&1; then
  echo "❌ GitHub 로그인이 필요합니다. 아래 명령을 먼저 실행하세요:"
  echo ""
  echo "   gh auth login"
  echo ""
  echo "   (GitHub.com → HTTPS → Login with a web browser 선택)"
  exit 1
fi

USER=$(gh api user -q .login)
echo "👤 GitHub 계정: $USER"

# 2. 변경 사항이 있으면 커밋
git add -A
git diff --cached --quiet || git commit -m "게임 업데이트"

# 3. 저장소가 없으면 생성 + 푸시, 있으면 푸시만
if ! gh repo view "$USER/heroes-gate" >/dev/null 2>&1; then
  echo "📦 GitHub 저장소 생성 중..."
  gh repo create heroes-gate --public --source=. --push
else
  echo "📤 변경 사항 푸시 중..."
  git push -u origin main 2>/dev/null || git push
fi

# 4. GitHub Pages 활성화 (main 브랜치 루트 폴더)
gh api "repos/$USER/heroes-gate/pages" -X POST \
  -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 || true

echo ""
echo "✅ 배포 완료! 1~2분 뒤 아래 무료 주소에서 어디서나 플레이할 수 있습니다:"
echo ""
echo "   🌏 https://$USER.github.io/heroes-gate/"
echo ""
