#!/bin/bash

# ===================================
# Dotfiles リセットスクリプト
# ===================================
# このスクリプトは、setup.shで設定した内容を削除し、
# バックアップから元の状態に復元します。
#
# 使い方:
#   chmod +x reset.sh
#   ./reset.sh
# ===================================

set -euo pipefail

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

# バックアップから復元する関数
restore_from_backup() {
    local file=$1

    # 最新のバックアップファイルを検索
    local latest_backup=$(ls -t "${file}.backup."* 2>/dev/null | head -n 1)

    if [ -n "$latest_backup" ]; then
        info "バックアップから復元しています: $latest_backup"
        mv "$latest_backup" "$file"
        success "復元が完了しました: $file"

        # 他のバックアップファイルを削除するか確認
        local other_backups=$(ls -t "${file}.backup."* 2>/dev/null | tail -n +2)
        if [ -n "$other_backups" ]; then
            echo ""
            read -r -p "他のバックアップファイルも削除しますか? (y/n) " response
            if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                echo "$other_backups" | xargs rm -f
                success "他のバックアップファイルを削除しました"
            fi
        fi
    else
        warning "バックアップファイルが見つかりませんでした: ${file}.backup.*"
    fi
}

echo ""
echo "=========================================="
echo "  Dotfiles リセットを開始します"
echo "=========================================="
echo ""
warning "この操作により、setup.shで設定した内容が削除されます"
warning "バックアップがある場合は、そこから復元されます"
echo ""
read -r -p "本当にリセットしますか? (y/n) " response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    info "リセットをキャンセルしました"
    exit 0
fi
echo ""

# 1. ~/.zshrcの復元
info "~/.zshrcを復元中..."
if [ -f "$HOME/.zshrc" ]; then
    # 現在の.zshrcを削除
    rm -f "$HOME/.zshrc"
    success "現在の~/.zshrcを削除しました"

    # バックアップから復元
    restore_from_backup "$HOME/.zshrc"
else
    warning "~/.zshrcが存在しません"
fi
echo ""

# 2. local.zshの削除
info "local.zshの削除を確認中..."
if [ -f "$DOTFILES_DIR/zsh/local.zsh" ]; then
    read -r -p "local.zshを削除しますか? (y/n) " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        rm -f "$DOTFILES_DIR/zsh/local.zsh"
        success "local.zshを削除しました"
    else
        info "local.zshの削除をスキップしました"
    fi
else
    info "local.zshが存在しません"
fi
echo ""

# 3. Zshプラグインの削除
info "Zshプラグインの削除を確認中..."
read -r -p "Zshプラグイン(zsh-autosuggestions, zsh-syntax-highlighting)を削除しますか? (y/n) " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # zsh-autosuggestions
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        rm -rf "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
        success "zsh-autosuggestionsを削除しました"
    else
        info "zsh-autosuggestionsが存在しません"
    fi

    # zsh-syntax-highlighting
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        rm -rf "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
        success "zsh-syntax-highlightingを削除しました"
    else
        info "zsh-syntax-highlightingが存在しません"
    fi
else
    info "Zshプラグインの削除をスキップしました"
fi
echo ""

# 4. Oh My Zshのアンインストール
info "Oh My Zshのアンインストールを確認中..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo ""
    warning "注意: Oh My Zshをアンインストールすると、カスタムテーマやプラグインも削除されます"
    read -r -p "Oh My Zshをアンインストールしますか? (y/n) " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        info "Oh My Zshをアンインストールしています..."
        # Oh My Zshの公式アンインストールスクリプトを使用
        if [ -f "$HOME/.oh-my-zsh/tools/uninstall.sh" ]; then
            env ZSH="$HOME/.oh-my-zsh" sh "$HOME/.oh-my-zsh/tools/uninstall.sh" || true
            success "Oh My Zshのアンインストールが完了しました"
        else
            # 手動で削除
            rm -rf "$HOME/.oh-my-zsh"
            success "Oh My Zshのディレクトリを削除しました"
        fi
    else
        info "Oh My Zshのアンインストールをスキップしました"
    fi
else
    info "Oh My Zshが存在しません"
fi
echo ""

# 5. fzfのアンインストール (macOSのみ)
OS_TYPE="$(uname -s)"
if [[ "$OS_TYPE" == "Darwin" ]] && command -v brew &> /dev/null; then
    info "fzfのアンインストールを確認中..."
    if command -v fzf &> /dev/null; then
        read -r -p "fzfをアンインストールしますか? (y/n) " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            info "fzfをアンインストールしています..."
            brew uninstall fzf || true

            # fzf設定ファイルの削除
            if [ -f "$HOME/.fzf.zsh" ]; then
                rm -f "$HOME/.fzf.zsh"
                success "~/.fzf.zshを削除しました"
            fi
            if [ -f "$HOME/.fzf.bash" ]; then
                rm -f "$HOME/.fzf.bash"
                success "~/.fzf.bashを削除しました"
            fi

            success "fzfのアンインストールが完了しました"
        else
            info "fzfのアンインストールをスキップしました"
        fi
    else
        info "fzfはインストールされていません"
    fi
    echo ""

    # 6. Nerd Fontsのアンインストール (macOSのみ)
    info "Nerd Fontsのアンインストールを確認中..."
    if brew list --cask font-meslo-lg-nerd-font &> /dev/null; then
        read -r -p "Meslo Nerd Fontをアンインストールしますか? (y/n) " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            info "Meslo Nerd Fontをアンインストールしています..."
            brew uninstall --cask font-meslo-lg-nerd-font || true
            success "Meslo Nerd Fontのアンインストールが完了しました"
            warning "ターミナルアプリのフォント設定を元に戻してください"
        else
            info "Meslo Nerd Fontのアンインストールをスキップしました"
        fi
    else
        info "Meslo Nerd Fontはインストールされていません"
    fi
    echo ""
fi

# 7. .zprofileの復元（Apple Siliconの場合、Homebrewのパス設定が追加されている可能性がある）
if [[ "$OS_TYPE" == "Darwin" ]] && [[ $(uname -m) == "arm64" ]]; then
    info "~/.zprofileの確認..."
    if [ -f "$HOME/.zprofile" ]; then
        if grep -q "/opt/homebrew/bin/brew shellenv" "$HOME/.zprofile"; then
            echo ""
            warning "~/.zprofileにHomebrewのパス設定が含まれています"
            info "以下の行が見つかりました:"
            grep "/opt/homebrew/bin/brew shellenv" "$HOME/.zprofile"
            echo ""
            read -r -p "この設定を削除しますか? (y/n) " response
            if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                # バックアップを作成
                cp "$HOME/.zprofile" "$HOME/.zprofile.backup.$(date +%Y%m%d_%H%M%S)"
                # Homebrewの設定行を削除
                sed -i.tmp '/\/opt\/homebrew\/bin\/brew shellenv/d' "$HOME/.zprofile"
                rm -f "$HOME/.zprofile.tmp"
                success "~/.zprofileからHomebrewのパス設定を削除しました"
            else
                info "~/.zprofileの変更をスキップしました"
            fi
        fi
    fi
    echo ""
fi

# 8. 完了メッセージ
echo ""
echo "=========================================="
echo "  リセットが完了しました！"
echo "=========================================="
echo ""
success "dotfilesの設定がリセットされました"
echo ""
info "次のステップ:"
echo "  1. 新しいターミナルを開いて、設定が元に戻っていることを確認してください"
echo "  2. 必要に応じて、手動で追加の設定を確認してください"
echo ""
