Had to add IBLocalizable directly because when using Carthage it was not working (nothing happened).
The issue seems to be with IBDesignables and IBInspectable objects distributed through frameworks, which Xcode does not detect.
Original repository https://github.com/PiXeL16/IBLocalizable
All credit goes to Chris Jimenez
