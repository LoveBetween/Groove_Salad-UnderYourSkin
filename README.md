# Under Your Skin
Under Your Skin creates new palette swap skins from palette textures. It also includes 1 new skin for every survivor as an example.

## Installation
This mod depends on the [Return Of Modding](https://github.com/return-of-modding/ReturnOfModding) loader:
* Download the latest Return Of Modding release from [Thunderstore](https://thunderstore.io/c/risk-of-rain-returns/p/ReturnOfModding/ReturnOfModding/versions/) or [Github](https://github.com/return-of-modding/ReturnOfModding/releases) and follow the installation instructions
    * Make sure to run the game once with Return Of Modding to generate the relevant folders
* Download this package, extract the package folder, and copy it into the `ReturnOfModding/plugins` folder. Your final folder structure should look like `ReturnOfModding/plugins/Groove_Salad-UnderYourSkin-X.X.X/*`

## Adding New Skins
To add a new skin, simply add an image to one of the survivor subfolders in `skins`. A palette texture is a 1-wide image where each color corresponds to a color on the survivor's base color palette. The included skins follow a naming scheme but the image name doesn't matter at all.

You can use the `dump_palette_sprites` config option to view all of the vanilla palettes. From there it should be pretty easy to figure out which index is associated with which color. Please contact me with any questions!

The in-game survivor sprites are the only sprites that are dynamically re-skinned in vanilla. The vanilla loadout and portrait sprites are all pre-computed. So, Under Your Skin will attempt to dynamically create loadout and portrait sprites based on your palette textures. It does a pretty good job, but the palettes usually have less color fidelity than these more detailed sprites. Please let me know if anything looks out-of-place on the loadout or portrait sprites.

## Configuration
A config file will generate in the `ReturnOfModding/config` folder:
* `dump_palette_sprites`: If true, the palette sprite of each survivor (including any new skins) will be dumped in `ReturnOfModding/plugins_data/Groove_Salad-UnderYourSkin/sprite_dump`. Seeing the base palettes is very helpful when making your own skins!
* `use_sprite_cache`: If true, palette swapped loadout and portrait sprites will be saved and loaded from a cache in `ReturnOfModding/plugins_data` instead of being generated at runtime. This will reduce load times, but loadout and portrait sprites **will not update to match changes in the palette texture**. You can manually delete the cached sprites to force them to re-generate.

## With Thanks To
* Everyone who has contributed to the Return Of Modding project and related tooling
* The helpful people in the modding server!

## Contact
For questions or bug reports, you can find me in the [RoRR Modding Server](https://discord.gg/VjS57cszMq) @Groove_Salad