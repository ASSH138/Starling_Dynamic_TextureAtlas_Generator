package  {
	
	public class FunctionData {
//contains a function and its parameters
public var args:Array=[];
public var Func:Function ;
public var thisObj:Object;
		public function FunctionData(thisObj:Object,Fn:Function ,...rest) {
			this.args=rest;
			this.Func=Fn;
			this.thisObj=thisObj;
			// constructor code
		}
public function run():void{
	this.Func.apply(thisObj,this.args);
}
	}
	
}
