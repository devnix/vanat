/*
 * MIT License
 *
 * Copyright (c) 2018 Vanat
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

using Vanat.Collections;
using Vanat.Exceptions;
using Vanat.Utils;
using Vanat.VJson;

namespace Vanat.Commands {

    /**
     * The {@code InstallCommand} class
     *
     * @author Robert San
     * @since 0.1.0
     */
    public class InstallCommand : Console.BaseCommand {
        public override string get_name () {
            return "install";
        }

        public override async void execute () {
            try {
                //
                //var vanat_lock_file = File.new_for_path (Environment.get_current_dir ()  + "/vanat.lock");

                //if (vanat_lock_file.query_exists ()) {

                //}
                //
                message (Environment.get_current_dir ().concat ("/vanat.json"));

                var vanat_json_file = File.new_for_path (Environment.get_current_dir ().concat ("/vanat.json"));

                if (!vanat_json_file.query_exists()) {
                    throw new FileOrDirectoryNotFoundException.MESSAGE("File doesn't exists\n");
                }

                var data_stream = new DataInputStream(vanat_json_file.read());
                string data = data_stream.read_until (StringUtil.EMPTY, null);
                VanatJson vanat_json = new VanatJson(data);

                ConsoleUtil.write_custom_color ("Loading json that are in the package", true, false, "yellow");

                int count = 0;
                foreach (string key in vanat_json.require.keys) {
                    string package;
                    string repository;

                    if (key.contains ("/")) {
                        string[] indexes = key.split("/");
                        package = indexes[0] +  "." + indexes[1];

                        repository = "com.github.".concat(package);
                        string url = "https://raw.githubusercontent.com/vpackagist/".concat(repository).concat("/master/").concat(repository).concat(".json");

                        var json = File.new_for_uri (url);

                        message(url);

                        if (!json.query_exists()) {
                            throw new FileOrDirectoryNotFoundException.MESSAGE("The json file of the url does not exist\n");
                        }

                        var data_stream_repository = new DataInputStream(json.read());
                        string data_repository = data_stream_repository.read_until (StringUtil.EMPTY, null);

                        File vendor_dir = File.new_for_path (Environment.get_current_dir ().concat("/vendor"));

                        if (!vendor_dir.query_exists ()) {
                            vendor_dir.make_directory ();
                        }

                        File package_dir = File.new_for_path (Environment.get_current_dir ().concat("/vendor/").concat(indexes[1]));

                        if (package_dir.query_exists ()) {
                            continue;
                        } else {
                            count++;
                        }

                        if (count > 1) {
                            ConsoleUtil.write ("\n");
                        }

                        ConsoleUtil.write_action (indexes[1], vanat_json.require.get(key), "Installing");

                        File target = File.new_for_uri ("https://github.com/".concat(key).concat("/archive/master.zip"));

                        if (!target.query_exists()) {
                            throw new FileOrDirectoryNotFoundException.MESSAGE("File or Directory doesn't exists\n");
                        }

                        File destination_zip = File.new_for_path (Path.build_filename (Environment.get_current_dir ().concat("/vendor/").concat(indexes[1] + "-master.zip")));
                        target.copy (destination_zip, FileCopyFlags.OVERWRITE, null, null);

                        FileUtil.decompress (destination_zip, indexes[1], true);

                        var meson_file = File.new_for_path (Environment.get_current_dir ().concat("/meson.build"));

                        // delete if file already exists
                        if (!meson_file.query_exists ()) {
                            throw new FileOrDirectoryNotFoundException.MESSAGE("File meson.build doesn't exists\n");
                        }

                        FileIOStream ios = meson_file.open_readwrite ();
                        var dostream = new DataOutputStream (ios.output_stream);

                        string text = "robertsanseries_ffmpeg_cli_wrapper_files,\nrobertsanseries_ffmpeg_cli_wrapper_files,\n";

                        uint8[] text_data = text.data;
                        long written = 0;

                        //while (written < text_data.length) {
                          //  written += dos.write (text_data[written:text_data.length]);
                        //}

                    }
                }

                if (count == 0) {
                    ConsoleUtil.write_custom_color ("> Nothing to install or update", true, false, "while");
                } else {
                    ConsoleUtil.write_custom_color ("✓ Completed", true, false, "cyan");
                }
            } catch (Error e) {
                error ("%s", e.message);
            }
        }
    }
}
