package arsupport.minko 
{
	import aerys.minko.scene.node.mesh.geometry.Geometry;
    import aerys.minko.type.stream.format.VertexFormat;
	import aerys.minko.type.stream.IndexStream;
    import aerys.minko.type.stream.IVertexStream;
    import aerys.minko.type.stream.VertexStream;
    import flash.geom.Point;
    import flash.geom.Rectangle;
	
	/**
     * ...
     * @author Eugene Zatepyakin
     */
    public final class MinkoCaptureGeometry extends Geometry 
    {
        public static const FILL_MODE_STRETCH:uint = 0;
        public static const FILL_MODE_PRESERVE_ASPECT_RATIO:uint = 1;
        public static const FILL_MODE_PRESERVE_ASPECT_RATIO_AND_FILL:uint = 2;
        public static const FILL_MODE_NO_STRETCH:uint = 3;
        
        public function MinkoCaptureGeometry(
                                                viewWidth:int, viewHeight:int,
                                                textureWidth:int, textureHeight:int,
                                                imageWidth:int, imageHeight:int,
                                                fillMode:uint = FILL_MODE_PRESERVE_ASPECT_RATIO_AND_FILL) 
        {
            var vertices:Vector.<Number>;
			var indices:Vector.<uint> = Vector.<uint>([0,1,2,1,3,2]);
            
            var u:Number, v:Number;
            var renderToTextureRect:Rectangle = new Rectangle();
            
            if (textureWidth > imageWidth) {
                renderToTextureRect.x = uint((textureWidth-imageWidth)*.5);
                renderToTextureRect.width = imageWidth;
            }
            else {
                renderToTextureRect.x = 0;
                renderToTextureRect.width = textureWidth;
            }

            if (textureHeight > imageHeight) {
                renderToTextureRect.y = uint((textureHeight-imageHeight)*.5);
                renderToTextureRect.height = imageHeight;
            }
            else {
                renderToTextureRect.y = 0;
                renderToTextureRect.height = textureHeight;
            }

            if (imageWidth > textureWidth) {
                u = 0;
            }
            else {
                u = renderToTextureRect.x / textureWidth;
            }
            if (imageHeight > textureHeight) {
                v = 0;
            }
            else {
                v = renderToTextureRect.y / textureHeight;
            }
            
            var widthScaling:Number, heightScaling:Number;
            var insetSize:Point = scaleWithAspect(imageWidth, imageHeight, viewWidth, viewHeight, true);
            
            switch(fillMode)
            {
                case 0://FillModeStretch:
                    widthScaling = 1.0;
                    heightScaling = 1.0;
                    break;
                case 1://FillModePreserveAspectRatio:
                    widthScaling = insetSize.x / viewWidth;
                    heightScaling = insetSize.y / viewHeight;
                    break;
                default:
                case 2://FillModePreserveAspectRatioAndFill:
                    widthScaling = viewHeight / insetSize.y;
                    heightScaling = viewWidth / insetSize.x;
                    break;
                case 3://FILL_MODE_NO_STRETCH
                    widthScaling = imageWidth / viewWidth;
                    heightScaling = imageHeight / viewHeight;
                    break;
            }
            
            vertices = Vector.<Number>([	-widthScaling, -heightScaling,0,   u, 1-v,
                                             widthScaling, -heightScaling,0,   1-u, 1-v,
                                            -widthScaling,  heightScaling,0,   u,   v,
                                             widthScaling,  heightScaling,0,   1-u,   v ]);
            
            var vstream:VertexStream = new VertexStream(
				0,
				VertexFormat.XYZ_UV,
				vertices
			);
			
			super(
				new <IVertexStream>[vstream],
				new IndexStream(0, indices),
                0, 2
			);
        }
        
        protected function scaleWithAspect(w:Number, h:Number, x:Number, y:Number, fill:Boolean = true):Point
        {
            var nw:int = y * w / h;
            var nh:int = x * h / w;
            if (int(fill) ^ int(nw >= x)) return new Point(nw || 1, y);
            return new Point(x, nh || 1);
        }
        
    }

}