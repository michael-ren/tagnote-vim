Tagnote Vim Plugin: Minimalist Note Organization
================================================

Installation
------------
On Vim 8 and later, install the package::

    cd ~/.vim/pack/plugins/start
    git clone https://github.com/michael-ren/tagnote-vim.git

For earlier versions of vim, copy `plugin/tagnote.vim` to `~/.vim/plugin/tagnote.vim`, creating the `plugin/` directory if needed.

This plugin requires the base Tagnote program to function. See the repository_ for installation instructions.

Configuration
-------------
By default, the configuration file is `~/.tag.config.json`, which is also the default of the main Tagnote program.

Although not recommended, to change the configuration file location, in your `.vimrc`, add::

    let g:TagnoteConfigurationFile = '~/.tagnote.json'

Remember to also invoke `tag` with the correct `-c` value.

The vim plugin respects settings from the main Tagnote configuration file. See the repository_ for more details.

.. _repository: https://githbub.com/michael-ren/tagnote
