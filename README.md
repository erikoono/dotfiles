# dotfiles

個人用のdotfiles管理リポジトリ

## 特徴

- **モジュール化**: 設定を種類ごとに分離して管理
- **ポータビリティ**: 複数の環境で簡単に同期可能
- **環境分離**: 環境固有の設定をGit管理から除外

## ディレクトリ構造

```
dotfiles/
├── .gitignore
├── README.md
├── setup.sh               # セットアップスクリプト
└── zsh/
    ├── common.zsh         # Oh My Zshの基本設定
    ├── plugins.zsh        # プラグイン固有の設定（fzf, autosuggestions等）
    ├── aliases.zsh        # カスタムエイリアス
    ├── local.zsh          # 環境依存設定（Git管理外）
    └── local.zsh.example  # 環境依存設定のテンプレート
```

## セットアップ

### 1. リポジトリのクローン

任意のディレクトリにリポジトリをクローンしてください。

```bash
# 例1: ホームディレクトリ直下にクローン
cd ~
git clone <repository-url> dotfiles
cd dotfiles

# 例2: 任意のディレクトリにクローン
mkdir -p ~/path/to/your/preferred/location
cd ~/path/to/your/preferred/location
git clone <repository-url> dotfiles
cd dotfiles
```

**注意**: クローン先のディレクトリは任意です。`setup.sh`スクリプトが自動的にクローン先を検出します。

### 2. セットアップスクリプトの実行

```bash
chmod +x setup.sh
./setup.sh
```

セットアップスクリプトは以下を自動的に実行します：

- **クローン先ディレクトリの自動検出**（どこにクローンしても動作します）
- Oh My Zshのインストール確認（未インストールの場合はインストール）
- 必要なZshプラグインのインストール
  - zsh-autosuggestions
  - zsh-syntax-highlighting
- Nerd Fontsのインストール（オプション）
- fzf（ファジーファインダー）のインストール（オプション）
- `~/.zshrc` の作成（実際のクローン先パスを自動設定、既存ファイルはバックアップ）
- `zsh/local.zsh` の初期化

### 3. Nerd Fontsのインストール（推奨）

Oh My Zshのテーマやプラグインでアイコンを正しく表示するため、Nerd Fontsのインストールを推奨します。

#### Homebrewを使用する場合（推奨）

```bash
# Homebrewがインストールされていない場合
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Nerd Fontsのインストール（例：Meslo Nerd Font）
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font

# その他の人気フォント
# brew install --cask font-hack-nerd-font
# brew install --cask font-fira-code-nerd-font
# brew install --cask font-jetbrains-mono-nerd-font
```

#### 手動でインストールする場合

1. [Nerd Fonts公式サイト](https://www.nerdfonts.com/font-downloads)からフォントをダウンロード
2. ダウンロードしたフォントファイル（.ttfまたは.otf）をダブルクリック
3. 「フォントをインストール」をクリック

#### ターミナルでフォントを設定

インストール後、ターミナルアプリの設定でNerd Fontを選択してください：

**iTerm2の場合:**
1. Preferences (⌘,) を開く
2. Profiles → Text → Font を選択
3. インストールしたNerd Font（例: MesloLGS NF）を選択

**macOSターミナルの場合:**
1. 環境設定 (⌘,) を開く
2. プロファイル → テキスト → フォント「変更」を選択
3. インストールしたNerd Fontを選択

### 4. 環境固有設定のカスタマイズ

```bash
# リポジトリをクローンした場所のパスを使用してください
# 例: ~/dotfiles にクローンした場合
vim ~/dotfiles/zsh/local.zsh

# 別の場所にクローンした場合
vim <クローンしたディレクトリ>/zsh/local.zsh
```

環境固有のPATHやエイリアスを `local.zsh` に追加してください。
このファイルはGit管理されないため、プライベートな設定も安全に記述できます。

### 5. 設定の反映

新しいターミナルを開くか、以下を実行：

```bash
source ~/.zshrc
```

## 手動セットアップ（オプション）

自動セットアップスクリプトを使わない場合：

### Oh My Zshのインストール

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### プラグインのインストール

```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### Nerd Fontsのインストール

```bash
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font
```

ターミナルの設定でインストールしたフォントを選択してください。

### fzfのインストール（オプション）

```bash
brew install fzf

# キーバインドとファジーコンプリートを有効化
$(brew --prefix)/opt/fzf/install
```

### 設定ファイルの準備

```bash
# 変数: dotfilesをクローンしたディレクトリのパスを設定してください
DOTFILES_DIR="<クローンしたディレクトリ>"  # 例: "$HOME/dotfiles" や "$HOME/path/to/dotfiles"

# local.zshの作成
cp $DOTFILES_DIR/zsh/local.zsh.example $DOTFILES_DIR/zsh/local.zsh

# ~/.zshrcの作成
cat > ~/.zshrc << EOF
DOTFILES_DIR="$DOTFILES_DIR"
[ -f "\$DOTFILES_DIR/zsh/common.zsh" ] && source "\$DOTFILES_DIR/zsh/common.zsh"
[ -f "\$DOTFILES_DIR/zsh/plugins.zsh" ] && source "\$DOTFILES_DIR/zsh/plugins.zsh"
[ -f "\$DOTFILES_DIR/zsh/aliases.zsh" ] && source "\$DOTFILES_DIR/zsh/aliases.zsh"
[ -f "\$DOTFILES_DIR/zsh/local.zsh" ] && source "\$DOTFILES_DIR/zsh/local.zsh"
EOF
```

## カスタマイズ方法

### エイリアスの追加

`zsh/aliases.zsh` にエイリアスを追加：

```bash
alias ll='ls -lah'
alias gs='git status'
```

### プラグイン設定の変更

`zsh/plugins.zsh` でプラグインの動作をカスタマイズ

### テーマの変更

`zsh/common.zsh` で `ZSH_THEME` を変更

## 新しい環境への適用

別のマシンで設定を使用する場合：

1. リポジトリをクローン
2. `./setup.sh` を実行
3. `zsh/local.zsh` を環境に合わせて編集

## トラブルシューティング

### 設定が反映されない場合

```bash
# 設定を再読み込み
source ~/.zshrc

# またはZshを再起動
exec zsh
```

### プラグインが動作しない場合

Oh My Zshとプラグインが正しくインストールされているか確認：

```bash
ls -la ~/.oh-my-zsh/custom/plugins/
```

### アイコンや記号が正しく表示されない場合

Nerd Fontsがインストールされ、ターミナルで選択されているか確認してください：

```bash
# インストール済みのNerd Fontsを確認（macOS）
brew list --cask | grep font

# または、システムフォントブックでNerd Fontを検索
open /System/Applications/Font\ Book.app
```

ターミナルアプリの設定で、フォント名に「Nerd Font」または「NF」が含まれるフォントを選択してください。

### Homebrewが見つからない場合

Homebrewをインストールしてください：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

インストール後、PATHを設定する必要がある場合があります（Apple Siliconの場合）：

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## ライセンス

MIT
