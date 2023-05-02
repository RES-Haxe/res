#if hl
final bios = new res.bios.hl.BIOS("RES", 4);
#elseif js
final bios = new res.bios.html5.BIOS();
#else
#error
#end
