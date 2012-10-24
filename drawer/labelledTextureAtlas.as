package drawer {
	import starling.textures.TextureAtlas;
	import starling.textures.Texture;

	public class labelledTextureAtlas extends TextureAtlas{
public var mFrameLabels:Object={};
public var mPivotPoints:Object={};
		public function labelledTextureAtlas(texture:Texture,XMLl:XML=null)  {
			super(texture,XMLl);
			// constructor code
		}

public function getImageTexture(name:String):Texture{
	var textName:String=name+"--0";
	var texture:Texture=this.getTexture(textName);
	return texture;
}
	}
	
}
