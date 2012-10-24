package  {
	import starling.animation.Juggler;
	import starling.display.MovieClip
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.events.Event;
import starling.core.Starling
import starling.display.DisplayObject;
//import drawer.labelledTextureAtlas;
import drawer.*
import flash.geom.Point;

	public dynamic class FlashMovieClip extends MovieClip {
//a movieclip with frame script functionality
protected var frameContainer:Vector.<uint> = new Vector.<uint>();
//maps flash movieclip frames to spritesheet frames.
protected var frameScripts:Array=[];
//map frame script functions to flash movieclip frames.
protected var frameLabels:Object={};
//maps labels to flash movieclip frames
protected var currentFlashFrame:Number=0;
public var Playing:Boolean=false;
protected var _speed:Number=1;
protected var currentFrameScriptFrame:int=-1;
protected var setLabel:String;
protected var onEnterFrame:Function=function(){return};
protected var playMode:String;
protected var repeats:uint=0;
public var looping:Boolean=false;
public static var jugglerList:Vector.<FlashMovieClip>= new Vector.<FlashMovieClip>();
public static function init(staged:DisplayObject):void{
	staged.addEventListener(Event.ENTER_FRAME,FlashMovieClip.juggle);
}
public static function juggle(evt:Event):void{
	//trace("juggle");
	for(var i:uint=0;i<FlashMovieClip.jugglerList.length;i++){
		var clip:FlashMovieClip=FlashMovieClip.jugglerList[i];
		//trace("juggle:"+clip);
		if(clip!=null){
		clip.EnterFrame(null);
		}
	}
}
public static function fromTextureAtlas(atlas:labelledTextureAtlas,frameRate:Number,clipName:String,labels:Array=null):FlashMovieClip{
	
	
	var allFrames:Vector.<Texture> = new Vector.<Texture>;
	var frameNo:int=0;
	var labeles:Object={};
	if(labels==null){
		labels= atlas.mFrameLabels[clipName];
		trace("labels:"+labels);
	}
	
	for(var i:int=0;i<labels.length;i++){
		var labell:String=labels[i];
		
		var n:int=0;
		
		while(true){
			try{
			var currentTexture:Texture=atlas.getTexture(clipName+"-"+labell+"-"+String(n));
			}catch(err:Error){
				break;
			}
			if(currentTexture==null){
				break;
			}
			if(n==0){
				labeles[labell]= frameNo;
		trace(labell+" = "+frameNo);
			}
			trace(frameNo+" = "+labell+"-"+String(n));
		allFrames.push(currentTexture);
		n++;
		frameNo++;
		if(n>int.MAX_VALUE){
			break;
		}
		}
	}
	var newMc:FlashMovieClip= new FlashMovieClip(allFrames,frameRate);
	if(atlas.mPivotPoints[clipName]!=null){
		var pivot:Point=atlas.mPivotPoints[clipName];
		newMc.pivotX= pivot.x;
		newMc.pivotY=pivot.y;
		trace("pivotPoint:"+pivot);
	}
	newMc.frameLabels=labeles;
	return newMc;
	
}
		public function FlashMovieClip(textures:Vector.<Texture>,framerate:Number=12) {
			super(textures,framerate);
			// constructor code
			//create a default frameContainer that maps flash frames to starling frames 1:1
			var totalFrame:uint=this.numFrames;
			for(var i:uint=0;i<totalFrame;i++){
				this.frameContainer[i]=i;
			}
			this.addEventListener(Event.ADDED_TO_STAGE,added);
			this.addEventListener(Event.REMOVED_FROM_STAGE,removed);
		}
		public function added(evt:Event):void{
			trace("add"+this);
			var index:int=FlashMovieClip.jugglerList.indexOf(this);
			if(index==-1){
				FlashMovieClip.jugglerList.push(this);
			}
			//Starling.current.juggler.add(this);
			//this.removeEventListener(Event.ADDED_TO_STAGE,added);
		}
		public function removed(evt:Event):void{
			var index:int=FlashMovieClip.jugglerList.indexOf(this);
			if(index!=-1){
				FlashMovieClip.jugglerList.splice(index,1);
			}
			//Starling.current.juggler.remove(this);
			//this.removeEventListener(Event.REMOVED_FROM_STAGE,removed);
		}
		public function Dispose():void{
			var index:int=FlashMovieClip.jugglerList.indexOf(this);
			if(index!=-1){
				FlashMovieClip.jugglerList.splice(index,1);
			}
			this.removeEventListeners(null);
		}
		public function get TotalFrames():uint{
			return this.numFrames;
		}
		/*public function addFrameInterval(spriteSheetFrame:uint=0,startFrame:uint=0,endFrame:Number=NaN,length:Number=NaN):void{
			if(isNaN(endFrame)&&!isNaN(length)){
				endFrame=startFrame+length;
			}
			endFrame=uint(endFrame);
			
			for(var s:uint=startFrame;s<=endFrame;s++){
				//this.frameContainer[s]=spriteSheetFrame
				this.frameContainer.splice(s,0,spriteSheetFrame);
			}
			if(this.currentFlashFrame>startFrame){
				this.currentFlashFrame+=(endFrame-startFrame);
			}
		}
		public function replaceFrameInterval(spriteSheetFrame:uint=0,startFrame:uint=0,endFrame:Number=NaN,length:Number=NaN):void{
			if(isNaN(endFrame)&&!isNaN(length)){
				endFrame=startFrame+length;
			}
			endFrame=uint(endFrame);
			
			for(var s:uint=startFrame;s<=endFrame;s++){
				this.frameContainer[s]=spriteSheetFrame;
				//this.frameContainer.splice(s,0,spriteSheetFrame);
			}
		}*/
		public function addLabel(frameNum:int,label:String):void{
			this.frameLabels[label]=frameNum;
		}
		public function addFrameScript(frame:*,script:*):void{
			var frameNum:int;
			if(this.frameLabels.hasOwnProperty(frame)){
				frameNum=this.frameLabels[frame];
			}else if (frame is int){
				frameNum=frame;
			}
			if(script is FunctionData){
			this.frameScripts[frameNum]=script;
			}else if (script is Function){
				var functionDat:FunctionData= new FunctionData(this,script);
				this.frameScripts[frameNum]=functionDat;
			}
		}
		public function removeFrameScript(frame:*):void{
			var frameNum:int
			if(this.frameLabels.hasOwnProperty(frame)){
				frameNum=this.frameLabels[frame];
			}else if (frame is int){
				frameNum=frame;
			}
			delete this.frameScripts[frameNum];
		}
		public function Loop(frame:String,setPlayMode:Boolean=true,goto:Boolean=false):void{
			  var frameNum:int;
			if(this.frameLabels.hasOwnProperty(frame)){
				frameNum=this.frameLabels[frame];
				this.Playing=true;
				if(goto||this.currentLabel!=frame){
				this.currentFrame=frameNum;
				
				this.setLabel=frame;
				//this.play();
//				Starling.current.juggler.add(this);
//			this.addEventListener(Event.ENTER_FRAME,this.EnterFrame);
			if(setPlayMode){
			this.playMode="loop";
			}
			
			if(this.frameScripts[frameNum]!=null){
					FunctionData(this.frameScripts[frameNum]).run();
					this.currentFrameScriptFrame=frameNum;
				}
			}
			}
		}
		public function Repeat(frame:String,times:int=1,goto:Boolean=false):void{
			  var frameNum:int;
			if(this.frameLabels.hasOwnProperty(frame)){
				frameNum=this.frameLabels[frame];
				this.Playing=true;
				if(goto||this.currentLabel!=frame){
				this.currentFrame=frameNum;
				this.setLabel=frame;
				//this.play();
//				Starling.current.juggler.add(this);
//				this.addEventListener(Event.ENTER_FRAME,this.EnterFrame);
				this.playMode="repeat";
				this.repeats=times;
			
			if(this.frameScripts[frameNum]!=null){
					FunctionData(this.frameScripts[frameNum]).run();
					this.currentFrameScriptFrame=frameNum;
				}
				}
			}
		}
		public function PlayOnce(frame:String,goto:Boolean=false):void{
			  var frameNum:int;
			if(this.frameLabels.hasOwnProperty(frame)){
				frameNum=this.frameLabels[frame];
				this.Playing=true;
				if(goto||this.currentLabel!=frame){
				this.currentFrame=frameNum;
				trace("playOnce:"+frame);
				this.setLabel=frame;
				//this.play();
//				Starling.current.juggler.add(this);
//				this.addEventListener(Event.ENTER_FRAME,this.EnterFrame);
				this.playMode="playOnce";
			
			if(this.frameScripts[frameNum]!=null){
					FunctionData(this.frameScripts[frameNum]).run();
					this.currentFrameScriptFrame=frameNum;
				}
				}
			}
		}
		public function gotoAndPlay(frame:*):void{
			//trace("gotoAndPlay:"+frame);
		    var frameNum:int;
			if(this.frameLabels.hasOwnProperty(frame)){
				frameNum=this.frameLabels[frame];
			}else if (frame is int){
				frameNum=frame;
			}
			//trace("frameNum:"+frameNum);
						this.currentFrame=frameNum;
			//this.currentFlashFrame=this.currentFrame;
			this.Playing=true;
			this.playMode=null;
			this.setLabel=null;
			//this.play();
//			Starling.current.juggler.add(this);
//			this.addEventListener(Event.ENTER_FRAME,this.EnterFrame);
			if(this.frameScripts[frameNum]!=null){
					FunctionData(this.frameScripts[frameNum]).run();
					this.currentFrameScriptFrame=frameNum;
				}
			/*if(frameNum>=0&&frameNum<this.frameContainer.length){
			this.currentFlashFrame=frameNum;
			this.gotoCurrentFrame();
			this.Playing=true;
			}else{
				if(frameNum>=this.frameContainer.length){
					this.currentFlashFrame=this.frameContainer.length-1
			this.gotoCurrentFrame();
			this.Playing=true;
				}
			}*/
		}
		public function gotoAndStop(frame:*):void{
			var frameNum:int;
			//trace("gotoAndStop:"+frame);
			if(this.frameLabels.hasOwnProperty(frame)){
				frameNum=this.frameLabels[frame];
			}else if (frame is int){
				frameNum=frame;
			}
			this.playMode=null;
			this.currentFrame=frameNum;
			//this.currentFlashFrame=this.currentFrame;
			//Starling.current.juggler.remove(this);
			//this.removeEventListener(Event.ENTER_FRAME,this.EnterFrame);
			this.setLabel=null;
			this.Playing=false;
			if(this.frameScripts[frameNum]!=null){
					FunctionData(this.frameScripts[frameNum]).run();
					this.currentFrameScriptFrame=frameNum;
				}
			
			/*if(frameNum>=0&&frameNum<this.frameContainer.length){
			this.currentFlashFrame=frameNum;
			this.gotoCurrentFrame();
			this.Playing=false;
			}else{
				if(frameNum>=this.frameContainer.length){
					this.currentFlashFrame=this.frameContainer.length-1
			this.gotoCurrentFrame();
			this.Playing=false;
				}
			}*/
		}
		public function Stop():void{
			
			this.Playing=false;
			this.setLabel=null;
			//Starling.current.juggler.remove(this);
//			this.removeEventListener(Event.ENTER_FRAME,this.EnterFrame);
		}
		//public function NextFrame():void{
//			var frame:int=this.currentFlashFrame+1;
//			if(frame>=0&&frame<this.frameContainer.length){
//			this.Playing=false;
//			this.currentFlashFrame++;
//			
//
//			this.gotoCurrentFrame();
//			this.Playing=false;
//			}else{
//				throw new Error("frame "+frame+ " is out of bounds!")
//			}
//		}
//		public function PrevFrame():void{
//			var frame:int=this.currentFlashFrame-1;
//			if(frame>=0&&frame<this.frameContainer.length){
//			this.Playing=false;
//			this.currentFlashFrame++;
//			
//
//			this.gotoCurrentFrame();
//			this.Playing=false;
//			}else{
//				throw new Error("frame "+frame+ " is out of bounds!")
//			}
//		}
		public function Play():void{
			
			this.Playing=true;
			//Starling.current.juggler.add(this);
//			this.addEventListener(Event.ENTER_FRAME,this.EnterFrame);
		}
		public function get currentFrameLabel():String{
			var label:String=null;
			var flashFrame:int=this.currentFrame;
			
			for(var labelname in this.frameLabels){
				var frameNum:int=this.frameLabels[labelname];
				if(frameNum==flashFrame){
					label=labelname;
				}
			}
			return label;
		}
		public function  FrameLabel(frame:int):String{
			var flashFrame:int=frame;
			if(frame>=this.TotalFrames){
				return "Error";
			}
			var closestLabel:String=null;
			var closestFrame:int=int.MAX_VALUE;
			for(var labelname in this.frameLabels){
				var frameNum:int=this.frameLabels[labelname];
				if(frameNum<=flashFrame){
					var diff:int=flashFrame-frameNum;
					if(diff<closestFrame){
						closestFrame=diff;
						closestLabel=labelname;
					}
				}
			}
			return closestLabel;
		}
		public function get currentLabel():String{
			var flashFrame:int=this.currentFrame;
			var closestLabel:String=null;
			var closestFrame:int=int.MAX_VALUE;
			for(var labelname in this.frameLabels){
				var frameNum:int=this.frameLabels[labelname];
				if(frameNum<=flashFrame){
					var diff:int=flashFrame-frameNum;
					if(diff<closestFrame){
						closestFrame=diff;
						closestLabel=labelname;
					}
				}
			}
			return closestLabel;
		}
		//public function gotoCurrentFrame():void{
//			var frameToDisplay:uint=this.frameContainer[int(this.currentFlashFrame)];
//			try{
//			this.currentFrame=frameToDisplay;
//			}catch(error:Error){
//				
//			}
//			if(this.frameScripts[this.currentFlashFrame]!=null){
//				FunctionData(this.frameScripts[this.currentFlashFrame]).run();
//			}
//		}
	//	public function set playbackSpeed(speed:Number):void{
//			/*var factor:Number=speed/this._speed;
//			for (var i:int=0;i<this.frameContainer.length;i++){
//				this.frameContainer[i]=int(this.frameContainer[i]*factor);
//			}*/
//			this._speed=speed;
//		}
		public function EnterFrame(evt:starling.events.Event):void{
			if(this.Playing){
				if(this.currentFrame<this.numFrames-1){
				this.currentFrame++;
				}else{
					if(this.looping){
					this.currentFrame=0;
					}
				}
				if(this.frameScripts[this.currentFrame]!=null){
					//if(this.currentFrame!=this.currentFrameScriptFrame){
					FunctionData(this.frameScripts[this.currentFrame]).run();
					this.currentFrameScriptFrame=this.currentFrame
					//}
				}
			
			if(this.setLabel!=null){
				if(this.playMode=="playOnce"){
					if(this.FrameLabel(this.currentFrame+1)!=this.setLabel){
						this.Stop();
					}
				}
				//trace(this.currentFrame+":"+this.currentLabel);
				//trace(this.FrameLabel(this.currentFrame+1));
			if(this.FrameLabel(this.currentFrame+1)!=this.setLabel){
				
				if(this.playMode=="loop"||this.playMode=="repeat"){
					//trace("loop back");
				this.Loop(this.setLabel,false,true);
				if(this.playMode=="repeat"){
					this.repeats--;
					if(this.repeats<=0){
						
						this.Stop();
					}
					
				}
				}
			}
			}
			}
		}

	}
	
}
