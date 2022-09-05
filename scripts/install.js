const assert = require("assert");
const fs = require("fs-extra");
const path = require("path");
const rimraf = require("rimraf");
const { getDotaPath } = require("./utils");
const readlineSync = require("readline-sync");
const { replace } = require("replace-json-property");

(async () => {
    let originalName = require("../package.json").name;
    let name = originalName;
    while (!/^[a-z]([\d_a-z]+)?$/.test(name)) {
        name = readlineSync.question(
            "Please your addon name! should start with a \nletter and consist only of lowercase characters,\ndigits and underscores, or input N to skip addon linking (NOT recommended): "
        );
        if (name.toLocaleLowerCase() == `n`) {
            console.log(`Skipping addon linking...`);
            return;
        }
        if (!/^[a-z]([\d_a-z]+)?$/.test(name)) {
            console.log("Invalid name!");
        }
    }

    if (name !== originalName) replace(path.resolve(__dirname, "..", "package.json"), "name", name, { spaces: 4 });

    if (process.platform !== "win32") {
        console.log("This script runs on windows only, Addon Linking is skipped.");
        return;
    }

    const dotaPath = await getDotaPath();
    if (dotaPath === undefined) {
        console.log("No Dota 2 installation found. Addon linking is skipped.");
        return;
    }

    for (const directoryName of ["game", "content"]) {
        const sourcePath = path.resolve(__dirname, "..", directoryName);
        assert(fs.existsSync(sourcePath), `Could not find '${sourcePath}'`);

        const targetRoot = path.join(dotaPath, directoryName, "dota_addons");
        assert(fs.existsSync(targetRoot), `Could not find '${targetRoot}'`);

        const targetPath = path.join(dotaPath, directoryName, "dota_addons", name);
        if (fs.existsSync(targetPath)) {
            const isCorrect = fs.lstatSync(sourcePath).isSymbolicLink() && fs.realpathSync(sourcePath) === targetPath;
            if (isCorrect) {
                console.log(`Skipping '${sourcePath}' since it is already linked`);
                continue;
            } else {
                // 移除目标文件夹的所有内容，
                console.log(`'${targetPath}' is already linked to another directory, removing`);
                fs.chmodSync(targetPath, "0755");
                await rimraf(targetPath, () => {
                    console.log("removed target path");
                    fs.moveSync(sourcePath, targetPath);
                    fs.symlinkSync(targetPath, sourcePath, "junction");
                    console.log(`Linked ${sourcePath} <==> ${targetPath}`);
                });
            }
        } else {
            fs.moveSync(sourcePath, targetPath);
            fs.symlinkSync(targetPath, sourcePath, "junction");
            console.log(`Linked ${sourcePath} <==> ${targetPath}`);
        }
    }
})().catch((error) => {
    console.error(error);
    process.exit(1);
});
