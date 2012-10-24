package  drawer{
	import flash.events.Event;
	public class DrawEvent extends Event{
public var clips:Vector.<drawData>
public static const CLIP_COMPLETE:String="CLIPCOMPLETE";
public static const BATCH_COMPLETE:String="BATCHCOMPLETE";
		public function DrawEvent(type:String,clips:Vector.<drawData>) {
			this.clips=clips;
			// constructor code
			super(type,false,false);
		}

	}
	
}
