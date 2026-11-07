# Source the theme implementation from this plugin's directory.
_ab_plugin_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$_ab_plugin_dir/bash-theme.bash"
unset _ab_plugin_dir
