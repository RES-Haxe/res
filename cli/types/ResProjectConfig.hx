package cli.types;

typedef DependenciesList = Array<Array<String>>;

enum abstract PlatformId(String) {
	var _all = '*';
	var js = "js";
	var hl = "hl";
}

typedef ResProjectConfig = {
	name:String,
	version:String,
	src:{
		path:String, main:String
	},
	build:{
		path:String
	},
	dist:{
		path:String, exeName:String
	},
	libs:Map<PlatformId, DependenciesList>,
	defs:Map<PlatformId, Array<Array<String>>>
};
