package pngSort
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	public class PngSorter extends Bitmap
	{
		private var _targetFile:File;
		private var _loader:Loader;
		
		public function PngSorter(f:File)
		{
			this._targetFile = f;
			var fs:FileStream = new FileStream();
			fs.open(f,FileMode.READ);
			var bytes:ByteArray = new ByteArray();
			fs.readBytes(bytes);
			fs.close();
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completedHandler);
			_loader.loadBytes(bytes);
		}
		
		private function completedHandler(evt:Event):void{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,completedHandler);
			this.bitmapData = (_loader.content as Bitmap).bitmapData;
		}
	}
}