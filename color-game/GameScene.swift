//
//  GameScene.swift
//  color-game
//
//  Created by Andrew Kutta on 2/21/22.
//

import SpriteKit
import GameplayKit
import GameController

class GameScene: SKScene {
    
    private var spinnyNode : SKShapeNode?
    private var vector : CGVector = CGVector.init(dx: 0, dy: 0)
    private var lastUpdateTimeInterval: TimeInterval = 0
    private static let minimumUpdateInterval = 1.0 / 60.0
    private var backgroundColorIndex : Int = 0;
    
    private var colors : [SKColor] = [
        SKColor.red, SKColor.green, SKColor.blue, SKColor.cyan,
        SKColor.yellow, SKColor.magenta, SKColor.orange, SKColor.purple
    ]
    
    private var backgroundColors : [SKColor] = [
        SKColor.black, SKColor.darkGray, SKColor.gray,
        SKColor.lightGray, SKColor.white, SKColor.lightGray, SKColor.gray, SKColor.darkGray
    ]
    
    func getButtons(controller: GCExtendedGamepad) -> [GCControllerButtonInput] {
        return [
            controller.dpad.left,
            controller.dpad.right,
            controller.dpad.up,
            controller.dpad.down,
            controller.buttonA,
            controller.buttonB,
            controller.buttonX,
            controller.buttonY
        ]
    }
    
    override func didMove(to view: SKView) {
        
        self.observeForGameControllers()
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.1
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    func observeForGameControllers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.connectControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
    }
    
    @objc func connectControllers(notification : Notification) {
        
        let movementHandler: GCControllerDirectionPadValueChangedHandler = { [unowned self] _, xValue, yValue in
            self.movementHandler(x: xValue, y: yValue)
        }
        
        let colorChangeHandler : GCControllerButtonTouchedChangedHandler = { _, _, pressed, touched in self.colorChangeHandler(pressed: pressed, touched: touched) }
        
        let controller = notification.object as! GCController
        
        if controller.extendedGamepad == nil {
            return
        }
        
        controller.extendedGamepad?.leftThumbstick.valueChangedHandler = movementHandler
        controller.extendedGamepad?.rightThumbstick.valueChangedHandler = movementHandler
        
        for button in self.getButtons(controller: controller.extendedGamepad!) {
            button.touchedChangedHandler = colorChangeHandler
        }
    }
    
    func movementHandler(x: Float, y: Float) {
        let length = hypotf(x, y)
        if length > 0.0 {
            self.vector = CGVector(dx: CGFloat(x), dy: CGFloat(y))
        }
        else {
            self.vector = CGVector(dx: 0, dy: 0)
        }
    }
    
    func colorChangeHandler(pressed: Bool, touched: Bool) {
        if !touched { return }
        self.backgroundColorIndex = (self.backgroundColorIndex + 1) % self.backgroundColors.count
    }
    
    func addNodeAtPoint(point: CGPoint, currentTime: TimeInterval) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = point
            n.strokeColor = self.colors[Int(currentTime.truncatingRemainder(dividingBy: Double(self.colors.count)))]
            self.addChild(n)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        let w = (self.size.height + self.size.width) * 0.1
        let width = ((self.size.width - w) / 2.0) * self.vector.dx
        let height = ((self.size.height - w) / 2.0) * self.vector.dy
        
        self.addNodeAtPoint(point: CGPoint.init(x: width, y: height), currentTime: currentTime)
        self.backgroundColor = self.backgroundColors[self.backgroundColorIndex]
    }
}
