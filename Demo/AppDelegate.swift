import UIKit
import LayoutKit
import Zelkova

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var program: Program<Model, Msg>?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        self.program = Program(model: 0, update: update, view: view)

        self.window = UIWindow()
        self.window?.rootViewController = self.program?.rootViewController
        self.window?.makeKeyAndVisible()

        return true
    }
}

let rootSize = UIScreen.main.bounds.size

enum Msg: Message
{
    case increment
    case decrement
}

typealias Model = Int

func update(state: Model, msg: Msg) -> Model?
{
    switch msg {
        case .increment:
            return state + 1
        case .decrement:
            return state - 1
    }
}

func view(_ model: Model, send: @escaping (Msg) -> ()) -> SizeLayout<UIView>
{
    func label(key: String, text: String) -> LabelLayout<UILabel>
    {
        return LabelLayout<UILabel>(
            text: .unattributed(text),
            font: .systemFont(ofSize: 48),
            alignment: .center,
            viewReuseId: key
        )
    }

    func button(key: String, title: String, msg: Msg, config: @escaping (UIButton) -> ()) -> ButtonLayout<UIButton>
    {
        return ButtonLayout<UIButton>(
            type: .custom,
            title: title,
            font: .systemFont(ofSize: 24),
            contentEdgeInsets: EdgeInsets(top: 10, left: 50, bottom: 10, right: 50),
            viewReuseId: key,
            config: {
                config($0)
                $0.setTitleColor(.white, for: .normal)
                $0.zelkova.addHandler(for: .touchUpInside) { _ in
                    send(msg)
                }
            }
        )
    }

    func stack() -> StackLayout<UIView>
    {
        return StackLayout<UIView>(
            axis: .vertical,
            spacing: 40,
            alignment: .center,
            viewReuseId: "Label & Buttons Stack",
            sublayouts: [
                label(key: "label1", text: "\(model)"),
                StackLayout<UIView>(
                    axis: .horizontal,
                    spacing: 20,
                    distribution: .fillEqualSize,
                    alignment: .center,
                    viewReuseId: "Buttons Stack",
                    sublayouts: [
                        button(key: "decrement", title: "-", msg: .decrement) {
                            $0.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
                        },
                        button(key: "increment", title: "+", msg: .increment) {
                            $0.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                        }
                    ],
                    config: { _ in }
                )
            ],
            config: { _ in }
        )
    }

    return SizeLayout<UIView>(
        size: rootSize,
        viewReuseId: "Root",
        sublayout: stack(),
        config: {
            $0.backgroundColor = .white
        }
    )
}
