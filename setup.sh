#!/bin/bash

# ===================================
# Dotfiles セットアップスクリプト
# ===================================
# このスクリプトは、dotfilesリポジトリをcloneした後に
# 設定を環境に適用するために使用します。
#
# 使い方:
#   chmod +x setup.sh
#   ./setup.sh
# ===================================

set -e

# 色付きの出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# dotfilesリポジトリのディレクトリ（このスクリプトがあるディレクトリを自動検出）
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ログ出力関数
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# バックアップ関数
backup_file() {
    local file=$1
    if [ -f "$file" ] || [ -L "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$file" "$backup"
        success "既存のファイルをバックアップしました: $backup"
    fi
}

# シンボリックリンクを作成する関数
create_symlink() {
    local source=$1
    local target=$2

    if [ -L "$target" ]; then
        info "シンボリックリンクが既に存在します: $target"
        local current_link=$(readlink "$target")
        if [ "$current_link" = "$source" ]; then
            info "既に正しいリンクが設定されています"
            return 0
        else
            warning "既存のシンボリックリンクを削除します"
            rm "$target"
        fi
    elif [ -e "$target" ]; then
        warning "既存のファイルが見つかりました: $target"
        backup_file "$target"
    fi

    ln -s "$source" "$target"
    success "シンボリックリンクを作成しました: $target -> $source"
}

echo ""
echo "=========================================="
echo "  Dotfiles セットアップを開始します"
echo "=========================================="
echo ""

# 1. Oh My Zshのチェック
info "Oh My Zshのインストールを確認中..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    warning "Oh My Zshがインストールされていません"
    echo ""
    echo "Oh My Zshをインストールしますか? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        info "Oh My Zshをインストールしています..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh My Zshのインストールが完了しました"
    else
        error "Oh My Zshが必要です。後でインストールしてください"
        exit 1
    fi
else
    success "Oh My Zshは既にインストールされています"
fi

# 2. プラグインのチェック
info "Zshプラグインのインストールを確認中..."

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    info "zsh-autosuggestionsをインストールしています..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    success "zsh-autosuggestionsのインストールが完了しました"
else
    success "zsh-autosuggestionsは既にインストールされています"
fi

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    info "zsh-syntax-highlightingをインストールしています..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    success "zsh-syntax-highlightingのインストールが完了しました"
else
    success "zsh-syntax-highlightingは既にインストールされています"
fi

# 3. Nerd Fontsのインストール
info "Nerd Fontsのインストールを確認中..."
echo ""
echo "Nerd Fontsをインストールしますか？"
echo "（Oh My Zshのテーマやプラグインでアイコンを正しく表示するために推奨されます）"
echo "(y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Homebrewのチェック
    if ! command -v brew &> /dev/null; then
        warning "Homebrewがインストールされていません"
        echo "Homebrewをインストールしますか? (y/n)"
        read -r brew_response
        if [[ "$brew_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            info "Homebrewをインストールしています..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Apple Siliconの場合、PATHを設定
            if [[ $(uname -m) == "arm64" ]]; then
                info "Apple Silicon用のPATHを設定しています..."
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi

            success "Homebrewのインストールが完了しました"
        else
            warning "Homebrewがないため、Nerd Fontsのインストールをスキップします"
            info "手動でインストールする場合は、https://www.nerdfonts.com/ を参照してください"
        fi
    fi

    # Homebrewがインストールされている場合、Nerd Fontsをインストール
    if command -v brew &> /dev/null; then
        info "Nerd Fontsをインストールしています..."

        # フォントcaskリポジトリを追加
        brew tap homebrew/cask-fonts 2>/dev/null || true

        # Meslo Nerd Fontをインストール
        if brew list --cask font-meslo-lg-nerd-font &> /dev/null; then
            success "Meslo Nerd Fontは既にインストールされています"
        else
            brew install --cask font-meslo-lg-nerd-font
            success "Meslo Nerd Fontのインストールが完了しました"
        fi

        echo ""
        info "フォントのインストールが完了しました"
        warning "ターミナルアプリの設定で 'MesloLGS NF' フォントを選択してください"
        echo ""
        echo "iTerm2の場合:"
        echo "  Preferences (⌘,) → Profiles → Text → Font"
        echo ""
        echo "macOSターミナルの場合:"
        echo "  環境設定 (⌘,) → プロファイル → テキスト → フォント"
        echo ""
    fi
else
    info "Nerd Fontsのインストールをスキップしました"
    warning "後でインストールする場合は、以下を実行してください:"
    echo "  brew tap homebrew/cask-fonts"
    echo "  brew install --cask font-meslo-lg-nerd-font"
fi
echo ""

# 4. .zshrcのシンボリックリンクを作成
info "~/.zshrcのセットアップ中..."

# まず、新しい.zshrcファイルを作成（シンボリックリンクではなく実ファイル）
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    backup_file "$HOME/.zshrc"
fi

cat > "$HOME/.zshrc" << EOF
# ===================================
# Zsh設定のエントリーポイント
# ===================================
# dotfilesリポジトリで管理している設定を読み込みます
# 詳細: $DOTFILES_DIR/zsh/

DOTFILES_DIR="$DOTFILES_DIR"

# 共通設定の読み込み
[ -f "\$DOTFILES_DIR/zsh/common.zsh" ] && source "\$DOTFILES_DIR/zsh/common.zsh"

# プラグイン設定の読み込み
[ -f "\$DOTFILES_DIR/zsh/plugins.zsh" ] && source "\$DOTFILES_DIR/zsh/plugins.zsh"

# エイリアスの読み込み
[ -f "\$DOTFILES_DIR/zsh/aliases.zsh" ] && source "\$DOTFILES_DIR/zsh/aliases.zsh"

# 環境固有の設定の読み込み（存在する場合のみ）
[ -f "\$DOTFILES_DIR/zsh/local.zsh" ] && source "\$DOTFILES_DIR/zsh/local.zsh"
EOF

success "~/.zshrcを作成しました"

# 5. local.zshのセットアップ
info "環境固有設定のセットアップ中..."
if [ ! -f "$DOTFILES_DIR/zsh/local.zsh" ]; then
    cp "$DOTFILES_DIR/zsh/local.zsh.example" "$DOTFILES_DIR/zsh/local.zsh"
    success "local.zshを作成しました"
    warning "環境固有の設定は $DOTFILES_DIR/zsh/local.zsh を編集してください"
else
    info "local.zshは既に存在します"
fi

# 6. 完了メッセージ
echo ""
echo "=========================================="
echo "  セットアップが完了しました！"
echo "=========================================="
echo ""
success "dotfilesの設定が適用されました"
echo ""
info "次のステップ:"
echo "  1. $DOTFILES_DIR/zsh/local.zsh を編集して、環境固有の設定を追加してください"
echo "  2. 新しいターミナルを開くか、次のコマンドを実行して設定を反映してください:"
echo "     source ~/.zshrc"
echo ""

# オプション: 今すぐ設定を反映するか確認
echo "今すぐ設定を反映しますか? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    exec zsh
fi
