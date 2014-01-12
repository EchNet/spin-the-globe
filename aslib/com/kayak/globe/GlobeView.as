package com.kayak.globe
{
    import com.kayak.motion.MotionUtil;
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import org.papervision3d.cameras.Camera3D;
    import org.papervision3d.materials.BitmapMaterial;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.Sphere;
    import org.papervision3d.scenes.MovieScene3D;

    /**
     * Rendering and redrawing of a globe.
     */
    public class GlobeView extends Sprite
    {
        public static const DEFAULT_RADIUS:int = 200;
        public static const DEFAULT_SEGMENTS_W:int = 24;
        public static const DEFAULT_SEGMENTS_H:int = 18;

        private var _radius:int;

        // Papervision objects
        private var _scene:MovieScene3D;
        private var _camera:Camera3D;
        private var _container:DisplayObject3D;
        private var _sphere:Sphere;

        // For tracking rotation:
        private var _cameraLongitude:Number = 104;  // where it starts out

        // For redraw logic:
        private var _dirty:Boolean = false;

        /**
         * Constructor.
         * @param bitmap   A Mercator projection bitmap to render
         *                 on the globe's surface
         */
        public function GlobeView(bitmap:Bitmap,
                                  radius:int = DEFAULT_RADIUS,
                                  segmentsW:int = DEFAULT_SEGMENTS_W,
                                  segmentsH:int = DEFAULT_SEGMENTS_H)
        {
            this._radius = radius;

            // Create the sphere.
            _sphere = new Sphere(new BitmapMaterial(bitmap.bitmapData),
                                 radius, segmentsW, segmentsH);

            // Create a container that holds the sphere and may be rotated
            // independently.
            _container = new DisplayObject3D();
            _container.addChild(_sphere);

            // Create a scene to be rendered into this object.
            _scene = new MovieScene3D(this);
            _scene.addChild(_container);

            cameraLongitude = 0;

            // Create a camera.
            _camera = new Camera3D(null, 10);
            _scene.renderCamera(_camera);
        }

        /**
         * cameraLatitude is the latitude of the point on the globe closest
         * to the camera eye.  Latitude is a value in the range [-90..90],
         * where -90 specifies the south pole, 90 specifies the north pole,
         * and 0 specifies the equator.  Input values outside this range
         * are invalid.
         */
        public function get cameraLatitude():Number
        {
            return _container.rotationX;
        }

        public function set cameraLatitude(value:Number):void
        {
            if (value < -90 || value > 90)
            {
                throw new Error (value + ": invalid latitude");
            }

            if (!MotionUtil.approximate(_container.rotationX, value))
            {
                _container.rotationX = value;
                _dirty = true;
            }
        }

        /**
         * cameraLongitude is the longitude of the point on the globe 
         * closest to the camera eye.  Longitude is a value in the range
         * [-180..180]. Longitude of zero specifies the vertical
         * line segment of the surface map that is midway between the left 
         * and right edges.  Any input value is valid, but values are 
         * normalized internally to [-180..180].
         */
        public function get cameraLongitude():Number
        {
            return _cameraLongitude;
        }

        public function set cameraLongitude(value:Number):void
        {
            var newLongitude:Number = normalizeRotation(value);
            var rotAngle:Number = newLongitude - _cameraLongitude;

            if (!MotionUtil.isZero(rotAngle))
            {
                _sphere.yaw(rotAngle);
                _cameraLongitude += rotAngle;
                _dirty = true;
            }
        }

        /**
         * zRotation is the rotation of the globe along the plane that is
         * always orthogonal to the camera eye.
         *
         * At zRotation zero, the globe is upright.  Any input value is 
         * valid, but values are normalized internally to the range [-180..180].
         *
         * The globe is upright initially.
         */
        public function get zRotation():Number
        {
            return _container.rotationZ;
        }

        public function set zRotation(value:Number):void
        {
            value = normalizeRotation(value);

            if (!MotionUtil.approximate(_container.rotationZ, value))
            {
                _container.rotationZ = value;
                _dirty = true;
            }
        }

        public function get cameraDistance():Number
        {
            return -_camera.z - _radius;
        }

        public function set cameraDistance(value:Number):void
        {
            if (value < 0)
            {
                throw new Error (value + ": invalid camera distance");
            }

            var newCameraZ:Number = -_radius - value;

            if (!MotionUtil.approximate(newCameraZ, _camera.z))
            {
                _camera.z = newCameraZ;
                _dirty = true;
            }
        }

        private static function normalizeRotation(value:Number):Number
        {
            value += 180;

            if (value > 360)
            {
                value %= 360;
            }
            else if (value < 0)
            {
                value += (Math.floor(Math.abs(value) / 360) + 1) * 360;
            }

            value -= 180;

            return value;
        }

        /**
         * Redraw the globe in its latest position.
         */
        public function redraw():void
        {
            if (_dirty)
            {
                _scene.renderCamera(_camera);
                _dirty = false;
            }
        }
    }
}
