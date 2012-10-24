package drawer{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
import flash.utils.getDefinitionByName;
import flash.events.Event;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.display.Bitmap;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.utils.Dictionary;
import flash.display.Shape;
import flash.text.TextField; 
import starling.textures.TextureAtlas;
import starling.textures.Texture;
import com.adobe.images.PNGEncoder;
import flash.utils.ByteArray;
import flash.net.FileReference;
import drawer.*
	public class drawData extends flash.display.Sprite {
		public var clip:MovieClip;
		public var clipName:String;
		public var bitmapDatas:Array= [];
		private var rect:Rectangle;
		public var labels:Array;
		private static var toDrawList:Array;
		private static var currentlyDrawingList:Vector.<drawData>;
		private static var completedDrawingList:Vector.<drawData>
		public static var batchLimit:uint=4;
		public static var debugMode:Boolean=true;
		private static var sprite:Sprite;
		//private static var currentHeight:Number;
		private var currentFrame:int;
		private  var currentY:Number;
		private static var staged:MovieClip;
		private static var eventDispatch:EventDispatcher= new Sprite;
		private static const debugCanvasSize:Number=300;
		private static var spriteDrawHeadX:Number;
		private static var spriteDrawHeadY:Number;
		public static var spriteScale:Number=2;
		public static var spriteX:Number=50;
		public static var spriteY:Number=50;
		private static const showSpriteFrames:int=125;
		private static var batchDrawInProgress:Boolean=false;
		private var boundingBoxBeingEvaluated:Boolean=false;
		private var boundingBoxData:Object;
		private var isDrawing:Boolean=false;
		private var pivotPoint:Point;
		
public static function cacheMovieClipData(Assetss:Object,atlas:labelledTextureAtlas,clipName:String,labels:Array=null,cacheLabel:String=null){
	
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
	if(atlas.mPivotPoints[clipName]!=null){
		var pivot:Point=atlas.mPivotPoints[clipName];
		Assetss[cacheLabel+"pivotPoint"]= pivot;
	}
	Assetss[cacheLabel+"atlas"] = atlas;
	Assetss[cacheLabel+"vector"]= allFrames;
	Assetss[cacheLabel+"labels"]=labeles;
	
}
		private  static function addLeadingZeros(base:int,number:int):String{
	var baseStr:String=base.toFixed(0);
	var numberStr:String=number.toFixed(0);
	var fix:String=numberStr;
	for(var char=numberStr.length;char<baseStr.length;char++){
		fix="0"+fix;
	}
	return fix;
	
}
		public static function createTextureAtlas(drawdataNames:Array,staged:MovieClip,debug:Boolean=false):labelledTextureAtlas{
			var drawDatas:Vector.<drawData>= new Vector.<drawData>;
			for(var d:int=0;d<drawdataNames.length;d++){
				var clipName:String=drawdataNames[d];
				for(var v:int=0;v<drawData.completedDrawingList.length;v++){
					var drawDatat:drawData= drawData.completedDrawingList[v];
					if(drawDatat.clipName==clipName){
						drawDatas.push(drawDatat);
						break;
					}
				}
			}
			var success:Boolean=false;
			var spriteSheetSize:int=256;
			var labell:Object={};
			while(!success){
				var abort:Boolean=false;
				var spriteSheet:BitmapData= new BitmapData(spriteSheetSize,spriteSheetSize,true,0);
				trace("new SPriteSheet "+spriteSheetSize+" x "+spriteSheetSize);
				var drawX:Number=0;
				var drawY:Number=0;
				var rectangles:Dictionary = new Dictionary(true);
				//maps bitmapData to its respective rectangle
				var names:Dictionary= new Dictionary(true);
				//maps bitmapData to its respective names.
				var lowestRowY:Number=0;
			for(var c:int=0;c<drawDatas.length;c++){
				
				var currentDrawData:drawData=drawDatas[c];
			 var bitmapDatas:Vector.<BitmapData>= currentDrawData.bitmapDatas;
			var currentlabelArray:Array=[];
			labell[currentDrawData.clipName]= currentlabelArray;
			  var nearest10:int=10;
				 while(nearest10<bitmapDatas.length){
					 nearest10*=10;
				 }
				 var prevLabel:String="";
				 var prevLabelIndex:uint=0;
			 for(var b:int=0;b<bitmapDatas.length;b++){
				
			 
				 var currentBitmapData:BitmapData= bitmapDatas[b];
				  if(drawX+currentBitmapData.width>spriteSheet.width){
					 drawX=0;
					 drawY=lowestRowY;
					 lowestRowY=drawY;
					 if(drawY>spriteSheetSize){
						 spriteSheetSize*=2;
						 trace("too large for current SPrite SHeet, size x2");
						 if(spriteSheetSize>2048){
							 throw( new Error("Max Texture Size Exceeded"));
							 return;
						 }
						 abort=true;
						 break;
					 }
				 }
				 var rect:Rectangle=new Rectangle(0,0,currentBitmapData.width,currentBitmapData.height);
				 var edgeY:Number=drawY+currentBitmapData.height;
				 var bitmapDataRect:Rectangle= new Rectangle(drawX,drawY,currentBitmapData.width,currentBitmapData.height);
				rectangles[currentBitmapData]= bitmapDataRect;
				
				//var prefix:String=drawData.addLeadingZeros(nearest10,b);
				if(currentDrawData.labels[b]!=null&&currentDrawData.labels[b]!=prevLabel){
					prevLabel=currentDrawData.labels[b];
					prevLabelIndex=0;
					currentlabelArray.push(prevLabel);
				}
				var prefix:String=prevLabel+"-"+prevLabelIndex;
				names[currentBitmapData]= String(currentDrawData.clipName)+"-"+String(prefix);
				prevLabelIndex++;
				 if(edgeY>lowestRowY){
					 lowestRowY=edgeY;
					 
				 }
				// trace("lowestRowY:"+lowestRowY);
			 var point:Point= new Point(drawX,drawY);
				 spriteSheet.copyPixels(currentBitmapData,rect,point);
				 trace("draw "+names[currentBitmapData]+" at "+drawX+","+drawY);
				 drawX+=currentBitmapData.width;
				
			 }
			 if(abort){
				 break;
			 }
			}
			if(!abort){
			success=true;
			}
			}
			trace("Final size:"+spriteSheet.width+" x "+spriteSheet.height);
			if(debug){
				var showBitMap:Bitmap= new Bitmap(spriteSheet);
				var sprite:MovieClip= new MovieClip();
				sprite.addChild(showBitMap);
				//draw rectangles
				for (var bit in rectangles){
					var rectt:Rectangle=rectangles[bit];
					var shape:Shape = new Shape();
					shape.graphics.lineStyle(1,0);
					shape.graphics.drawRect(rectt.x,rectt.y,rectt.width,rectt.height);
					var name:String=names[bit];
					sprite.addChild(shape);
					var textF:TextField= new TextField();
					textF.text=name;
					textF.x=rectt.x;
					textF.y=rectt.y;
					textF.scaleX=0.5;
					textF.scaleY=0.5;
					textF.textColor=0xFF0000;
					textF.wordWrap=true;
					sprite.addChild(textF);
					//save to file
					
					
				}
				
				sprite.scaleX=drawData.spriteScale;
				sprite.scaleY=drawData.spriteScale;
				sprite.x=0;
				sprite.y=0;
				//display the final bitmap;
				var container:Sprite= new Sprite();
				container.addChild(sprite);
				var bitmapDebug:BitmapData=new BitmapData(container.width, container.height);
					bitmapDebug.draw(container);
					
					var byteData:ByteArray=com.adobe.images.PNGEncoder.encode(bitmapDebug);
					var fileR:FileReference= new FileReference();
					
					fileR.save(byteData,"spritesheet.png");
				//staged.addChild(sprite);
				sprite.timer=0;
				sprite.addEventListener(Event.ENTER_FRAME,drawData.spriteAdvance);
			}
			//create the atlas.
			var texture:Texture = Texture.fromBitmapData(spriteSheet,false);
			var textureAtlas:labelledTextureAtlas= new labelledTextureAtlas(texture);
			textureAtlas.mFrameLabels= labell;
			for (var bit2 in rectangles){
				var rectBit:Rectangle=rectangles[bit2];
				var namet:String=names[bit2];
				textureAtlas.addRegion(namet,rectBit);
			}
			return textureAtlas;
		}
		public static function spriteAdvance(evt:Event):void{
			var sprite:MovieClip=MovieClip(evt.currentTarget);
			sprite.timer++;
			if(sprite.timer>drawData.showSpriteFrames){
				sprite.parent.removeChild(sprite);
				sprite.removeEventListener(Event.ENTER_FRAME,arguments.callee);
			}
		}
		
		public static function beginBatchDraw(evt:Event,drawList:Array,staged:MovieClip=null):void{
			drawData.toDrawList=drawList.concat();
			drawData.currentlyDrawingList= new Vector.<drawData>;
			/*drawData.currentlyDrawingList.toString=function():String{
				var str="";
				for(var i:int=0;i<this.length;i++){
					str+=this[i].clipName;
					
				}
				return str;
			}*/
			drawData.completedDrawingList= new Vector.<drawData>;
			drawData.staged=staged;
			if(drawData.debugMode){
				drawData.spriteDrawHeadX=0;
				drawData.spriteDrawHeadY=0;
				//drawData.currentHeight=0;
				drawData.sprite= new Sprite();
				drawData.sprite.scaleX=drawData.spriteScale;
				drawData.sprite.scaleY=drawData.spriteScale;
				drawData.sprite.x=drawData.spriteX;
				drawData.sprite.y=drawData.spriteY;
				staged.addChild(drawData.sprite);
				
			}
			while(drawData.currentlyDrawingList.length<drawData.batchLimit&&drawData.toDrawList.length>0){
				drawData.addDrawElement();
				trace("add Element");
			}
			if(!drawData.batchDrawInProgress){
			drawData.staged.addEventListener(Event.ENTER_FRAME,drawData.enterFrame);
			drawData.staged.addEventListener(Event.EXIT_FRAME,drawData.exitFrame);
			}
		}
		private static function  onDrawComplete(completed:drawData):void{
			trace(completed.clipName+"complete");
	      var index:int=drawData.currentlyDrawingList.indexOf(completed);
	     drawData.currentlyDrawingList.splice(index,1);
		 trace(drawData.currentlyDrawingList);
	     if(drawData.currentlyDrawingList.length<=0&&drawData.toDrawList.length<=0){
			 if(drawData.debugMode){
			drawData.staged.removeChild( drawData.sprite);
			 }
			drawData.staged.dispatchEvent(new DrawEvent(DrawEvent.BATCH_COMPLETE,drawData.completedDrawingList));
			//Game.game.initGame();
			drawData.batchDrawInProgress=false;
			drawData.staged.removeEventListener(Event.ENTER_FRAME,drawData.enterFrame);
			drawData.staged.removeEventListener(Event.EXIT_FRAME,drawData.exitFrame);
		 trace("allDrawComplete");
	     }else{
		  drawData.addDrawElement();
	     }
      }
	  private static function addDrawElement():void{
		  if(drawData.toDrawList.length>0){
		  var ele:*= drawData.toDrawList.pop();
		  if(ele is flash.display.MovieClip){
			  var Ddata:drawData=new drawData(null,null,ele);
		  }else if (ele is FunctionData){
			  var Ddata:drawData= new drawData(null,ele,null);
		  }else if (ele is String){
			  var Ddata:drawData= new drawData(ele,null,null);
		  }
				
				trace(drawData.currentlyDrawingList);
		  }
	  }
	  private static function enterFrame(evt:Event):void{
		  trace("ENTER_FRAME");
		  for(var d:int=0;d<drawData.currentlyDrawingList.length;d++){
			  var dawData:drawData= drawData.currentlyDrawingList[d];
			  if(dawData.isDrawing){
			  dawData.advanceFrame(null);
			  }
		  }
	  }
	    private static function exitFrame(evt:Event):void{
		  trace("EXIT_FRAME");
		  for(var d:int=0;d<drawData.currentlyDrawingList.length;d++){
			  var dawData:drawData= drawData.currentlyDrawingList[d];
			    if(dawData.isDrawing){
			  dawData.iterateDrawFrame(null);
				}
				if(dawData.boundingBoxBeingEvaluated){
					dawData.iterateBoundingBox();
				}
		  }
	  }
		public function drawData(clipName:String,clip:*=null,functiondata:FunctionData=null):void{
			trace("drawData("+clipName+","+clip+","+color+");");
			drawData.currentlyDrawingList.push(this);
			//this.labels=new Array;
			if(clipName!=null){
			this.clipName=clipName;
			var clas:Class=Class(getDefinitionByName(clipName));
			this.clip= new clas();
			}
			if(functiondata!=null){
				this.clip= functiondata.construct();
				this.clipName=functiondata.className;
				}
				
			if (clip!=null&&(clip is MovieClip)){
				this.clip=clip;
				this.clipName=clip.name;
			}
			this.labels= [];
			this.beginGetBoundingBox();
			trace(this.clipName+" boundingbox:"+this.rect);
			if(drawData.debugMode){
				
				drawData.staged.addChild(this.clip);
				this.clip.x=100*drawData.currentlyDrawingList.indexOf(this);
				this.clip.y=100;
				//this.currentY=drawData.currentHeight;
				//drawData.currentHeight+=this.rect.height;
			}
			//drawData.staged.addEventListener(Event.ENTER_FRAME,advanceFrame);
			//drawData.staged.addEventListener(Event.EXIT_FRAME,iterateDrawFrame);
			this.currentFrame=1;
			this.clip.gotoAndPlay(this.currentFrame);
			
			
		}
		
		public function beginGetBoundingBox():void{
			this.boundingBoxBeingEvaluated=true;
			trace("start Bounding box eval:"+this.clipName);
			this.boundingBoxData={};
			boundingBoxData.minLeft= 100000;
			boundingBoxData.maxRight = -100000;
			boundingBoxData.minTop = 100000;
			boundingBoxData.maxBottom = -100000;
			//this.currentFrame=1;
			this.clip.gotoAndPlay(1);
		}
		public function iterateBoundingBox():void{
			//this.currentFrame++;
			trace("evalBB:"+this.clipName+":"+this.clip.currentFrame);
			trace(this.clip.isPlaying+"playing");
			if(!this.clip.isPlaying){
		
			}
			var rect:Rectangle = this.clip.getBounds(this.clip);
				var left:Number = rect.left;
				var right:Number = rect.right;
				var top:Number = rect.top;
				var bottom:Number = rect.bottom;
				if (left<this.boundingBoxData.minLeft) {
					this.boundingBoxData.minLeft = left;
				}
				if (right>this.boundingBoxData.maxRight) {
					this.boundingBoxData.maxRight = right;
				}
				if (top<this.boundingBoxData.minTop) {
					this.boundingBoxData.minTop = top;
				}
				if (bottom>this.boundingBoxData.maxBottom) {
					this.boundingBoxData.maxBottom = bottom;
				}
				if (this.clip.currentFrame >= this.clip.totalFrames) {
					this.getBoundingBoxComplete();
				}
		}
		public function getBoundingBoxComplete():void{
			var boundingBox:Rectangle = new Rectangle(this.boundingBoxData.minLeft,this.boundingBoxData.minTop);
			boundingBox.right = this.boundingBoxData.maxRight;
			boundingBox.bottom = this.boundingBoxData.maxBottom;
			this.boundingBoxBeingEvaluated=false;
			this.rect=boundingBox;
			trace("finished Bounding box:"+this.clipName);
			if(this.clip.currentFrame!=1){
			while(this.clip.numChildren>0){
				this.clip.removeChildAt(0);
			}
			}
			this.beginDraw();
		}
		public function beginDraw():void{
			trace("beginDraw:"+this.clipName);
			this.currentFrame=1;
			this.clip.gotoAndPlay(this.currentFrame);
			this.isDrawing=true;
			this.drawFrame(this.clip,this.rect);
		}
		//DEPRECATED
		//public function getBoundingBox(clip:MovieClip):Rectangle {
//			
//			var minLeft:Number = 100000;
//			var maxRight:Number = -100000;
//			var minTop:Number = 100000;
//			var maxBottom:Number = -100000;
//			for (var f1:uint=1; f1<=clip.totalFrames; f1++) {
//				clip.gotoAndStop(f1);
//				var rect:Rectangle = clip.getBounds(clip);
//				var left:Number = rect.left;
//				var right:Number = rect.right;
//				var top:Number = rect.top;
//				var bottom:Number = rect.bottom;
//				if (left<minLeft) {
//					minLeft = left;
//				}
//				if (right>maxRight) {
//					maxRight = right;
//				}
//				if (top<minTop) {
//					minTop = top;
//				}
//				if (bottom>maxBottom) {
//					maxBottom = bottom;
//				}
//			}
//			var boundingBox:Rectangle = new Rectangle(minLeft,minTop);
//			boundingBox.right = maxRight;
//			boundingBox.bottom = maxBottom;
//			this.boundingBoxBeingEvaluated=false;
//			this.rect=boundingBox;
//			trace("finished Bounding box:"+this.clipName);
//			
//			return boundingBox;
//		}

		public function drawFrame(clip:MovieClip,boundingBox:Rectangle):void {
			if(this.clip.currentFrameLabel!=null){
				//trace("add label:"+this.clip.currentFrameLabel);
				this.labels[this.clip.currentFrame-1]=this.clip.currentFrameLabel;
			}
			var bitmapData:BitmapData = new BitmapData(boundingBox.width,boundingBox.height,true,0x00FFFFFF);
			var bounds:Rectangle = boundingBox;
			var matrix:Matrix= new Matrix();
			matrix.translate(-bounds.x,-bounds.y);
			bitmapData.draw(clip,matrix);

			
			
			this.bitmapDatas[clip.currentFrame-1] = bitmapData;
			//trace("addBitmapData");
			if(drawData.debugMode){
			var bitmap:Bitmap = new Bitmap(bitmapData);
			drawData.spriteDrawHeadX+=bitmap.width;
			if(drawData.spriteDrawHeadX>drawData.debugCanvasSize){
				drawData.spriteDrawHeadY+=bitmap.height;
				drawData.spriteDrawHeadX=0;
			}
			bitmap.x = drawData.spriteDrawHeadX;
			
			
			//0 + clip.currentFrame * boundingBox.width;
			bitmap.y = drawData.spriteDrawHeadY;
			if(drawData.spriteDrawHeadY>drawData.debugCanvasSize){
				drawData.spriteDrawHeadX=0;
				drawData.spriteDrawHeadY=0;
				while(drawData.sprite.numChildren>0){
					drawData.sprite.removeChildAt(0);
				}
			}
			//this.currentY;
			drawData.sprite.addChild(bitmap);
			}
		}

		public function advanceFrame(evt:Event):void {
			//trace("advance:"+this.clipName);
			//this.clip.nextFrame();
			
		}
		public function onDrawComplete():void{
			drawData.completedDrawingList.push(this);
			if(drawData.debugMode){
				drawData.staged.removeChild(this.clip);
			}
			drawData.staged.dispatchEvent(new DrawEvent(DrawEvent.CLIP_COMPLETE,new <drawData>[this]));
			//Assetss.createTextureArray(this.clipName,this.bitmapDatas);
		}
		public function iterateDrawFrame(evt:Event):void {
			
			this.drawFrame(this.clip,this.rect);
			trace("draw:"+this.clipName+":"+this.clip.currentFrame);
			if (this.clip.currentFrame >= this.clip.totalFrames) {
				this.onDrawComplete();
				drawData.onDrawComplete(this);
				//this.clip.removeEventListener(Event.ENTER_FRAME,advanceFrame);
				//this.clip.removeEventListener(Event.EXIT_FRAME,iterateDrawFrame);
			}
			this.currentFrame++;
			//this.clip.gotoAndStop(this.currentFrame);
		}
	}
}