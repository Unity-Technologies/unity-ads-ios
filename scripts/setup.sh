set -o xtrace

brew update
brew install rbenv
if ! grep -q 'export PATH="$HOME/.rbenv/bin:$PATH"' ~/.bash_profile; then
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
fi
if ! grep -q 'eval "$(rbenv init -)"' ~/.bash_profile; then
	echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
fi
if ! grep -q 'export LANG=en_US.UTF-8' ~/.bash_profile; then
	echo 'export LANG=en_US.UTF-8' >> ~/.bash_profile
fi
if ! grep -q 'export LANGUAGE=en_US.UTF-8' ~/.bash_profile; then
	echo 'export LANGUAGE=en_US.UTF-8' >> ~/.bash_profile
fi
if ! grep -q 'export LC_ALL=en_US.UTF-8' ~/.bash_profile; then
	echo 'export LC_ALL=en_US.UTF-8' >> ~/.bash_profile
fi
source ~/.bash_profile
echo n | rbenv install 2.3.1
rbenv shell 2.3.1
gem install bundler
bundle install
xcversion select 9.4
xcversion install-cli-tools
git clean -fdx

./generate-project.rb
