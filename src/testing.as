// void Main() {
//     Meta::Plugin@[]@ plugins = Meta::AllPlugins();

//     array<string> pluginNames;

//     for (uint i = 0; i < plugins.Length; i++) {
//         Meta::Plugin@ plugin = plugins[i];

//         pluginNames.InsertLast(plugin.Name);

//     }

//     print(StringArrayToSingleString(pluginNames));

//     _IO::File::WriteFile(IO::FromStorageFolder("plugin_list.txt"), StringArrayToSingleString(pluginNames));
// }

// string StringArrayToSingleString(array<string> arr) {
//     string result = "";

//     for (uint i = 0; i < arr.Length; i++) {
//         result += arr[i];

//         if (i != arr.Length - 1) {
//             result += ", ";
//         }
//     }

//     return result;
// }