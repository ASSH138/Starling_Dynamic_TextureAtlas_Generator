package  {
	import flash.utils.getDefinitionByName;
	
	public class FunctionData {
//contains a function and its parameters
public var args:Array=[];
public var Func:Function ;
public var className:String=null;

public var thisObj:Object;
		public function FunctionData(thisObj:Object,Fn:* ,...rest) {
			//pass a Function object if this stores a function, and your arguments in...rest,
			//to run function, call run();
			//pass the className:String if thie stores a class constructor, and your arguments in ...rest
			//to instantiate, call construct, returns the instance which was created.
			this.args=rest;
			if(Fn is Function){
			this.Func=Fn;
			}
			if(Fn is String){
				this.className=Fn
			}
			this.thisObj=thisObj;
			// clastructor code
		}
public function run():void{
	this.Func.apply(thisObj,this.args);
}
public function construct():*{
	var args:Array=this.args;
	var clas:Class= flash.utils.getDefinitionByName(this.className);
	var object:Object;
				switch (this.args.length){
					case 0:
					object= ( new clas);
					break;
					case 1:
					object= (new clas (args[0]));
					break;
					case 2:
					object= (new clas (args[0],args[1]));
					break;
					case 3:
					object= (new clas (args[0],args[1],args[2]));
					break;
					case 4:
					object= (new clas (args[0],args[1],args[2],args[3]));
					break;
					case 5:
					object= (new clas (args[0],args[1],args[2],args[3],args[4]));
					break;
					case 6:
					object= (new clas (args[0],args[1],args[2],args[3],args[4],args[5]));
					break;
					case 7:
					object= (new clas (args[0],args[1],args[2],args[3],args[4],args[5],args[6]));
					break;
				}
				return object;
}
	}
	
}
