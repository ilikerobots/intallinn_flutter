import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:glob/glob.dart';
import 'package:yaml/yaml.dart';
import 'package:in_tallinn_content/license/license.dart';

//Adjust the following to point to cloned repo location
const INTALLINN_CONTENT_PATH = "/home/mike/WebstormProjects/inTallinn_content/";

const YAML_PATH = "$INTALLINN_CONTENT_PATH/assets/image/section_photo.yaml";
const IMG_INPATH = "$INTALLINN_CONTENT_PATH/assets/image/";
const IMG_OUTPATH = "assets/image/section/";
const MD_INPATH = "$INTALLINN_CONTENT_PATH/web/content/section/";
const MD_OUTPATH = "assets/content/";

const CONVERT_SCRIPT = "convert";
const ASPECT_RATIO = "2:1";
const FINAL_GEOMETRY = "600x300^";

const tmpSubdirName = 'inTallinn_section_img';

const QUALITY = 42;


main() async {


  if (! (new File(YAML_PATH).existsSync())) {
    print("Could not locate intallinn content yaml at $YAML_PATH.");
    print("Set INTALLINN_CONTENT_PATH to a valid intallinn_content repo.");
    exit(1);
  }

  syncImages();
  syncMarkdown();


}

Future syncMarkdown() async {
  Directory outDir = new Directory(MD_OUTPATH);
  if (!outDir.existsSync()) {
    outDir.createSync();
  }
  final Glob markdownGlob = new Glob("${MD_INPATH}*.md");
  for (FileSystemEntity entity in markdownGlob.listSync()) {
    if (entity is File) {
      String oPath = MD_OUTPATH + path.basename(entity.path);
      print("Copying ${entity.path} to ${oPath}");
      entity.copySync(oPath);
    }
  }

}

Future syncImages() async {
  String inPath = path.absolute(IMG_INPATH);
  String outPath = path.absolute(IMG_OUTPATH);

  Directory outDir = new Directory(outPath);
  if (!outDir.existsSync()) {
    await outDir.create(recursive: true);
  }

  String contents = await new File(YAML_PATH).readAsString();
  var yaml = loadYaml(contents);

  Directory tmpDir = await Directory.systemTemp.createTemp(tmpSubdirName);

  await Future.forEach(yaml['photos'], (Map f) async {
    print("Converting $IMG_INPATH${f['in_filename']} " +
        "to $IMG_OUTPATH${f['out_filename']}");

    String iFile = path.join(inPath, f['in_filename']);
    String oFile = path.join(outPath, f['out_filename']);
    String tmpBaseName = path.basenameWithoutExtension(iFile);
    String tmpFileName = "${tmpDir.path}/$tmpBaseName.cache.jpg";

    new File(iFile).copySync(tmpFileName); //copy to tmp location

    String cropGravity = f.containsKey('crop_gravity')
        ? f['crop_gravity']
        : "center";

    await doImageConvert(CONVERT_SCRIPT, ['-quality', '100'], tmpFileName);
    await doImageConvert(CONVERT_SCRIPT,
        ["-geometry", FINAL_GEOMETRY, "-gravity", cropGravity, "-crop", "$FINAL_GEOMETRY+0+0", '-quality', '$QUALITY'], tmpFileName);

    new File(tmpFileName).copySync(oFile); //copy to final location
    writeLicenseFile(f['license'], "$oFile.license");
  });
  tmpDir.delete(recursive: true);
}


Future<Null> doImageConvert(final String cmd, final List<String> args,
    final String filename) async {
  List<String> thisArgs = new List.from(args)
    ..add(filename)..add(filename);
  await exitOnFail(Process.run(cmd, thisArgs));
  return;
}

Future<Null> writeLicenseFile(Map<String, String> licenseAttribs,
    String fName) async {
  License l = new LicenseFactory().getLicenseFromString(licenseAttribs['type']);
  Map<String, dynamic> out = {}..addAll(licenseAttribs);
  out['attribution_text'] = l.getAttribution(licenseAttribs['author']);
  out['attribution_required'] = l.attributionRequired;
  await new File(fName).create()
    ..writeAsString(JSON.encode(out));
}

Future<Null> exitOnFail(Future<ProcessResult> resF) async {
  ProcessResult res = await resF;
  if (res.exitCode != 0) {
    stderr.writeln(res.stderr);
    exit(res.exitCode);
  }
  return;
}
