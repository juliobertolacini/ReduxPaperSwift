# ReduxPaperSwift
Uma simples abordagem para aprender os primórdios de Redux em Swift.

## Introdução
Redux é a implementação de um padrão arquitetural de software que prioriza o fluxo de dados unidirecional.
Foi criada a partir da arquitetura Flux (desenvolvida pelo Facebook), vem crescendo bastante no desenvolvimento de aplicações e promete grandes vantagens na sua utilização.
Ela é uma alternativa a outros padrões arquiteturais como, por exemplo: MVC, MVVM, Viper e CleanSwift.

## Vantagens
Uma das grandes promessas do Redux é criar restrições que incentivam um desenvolvimento de software mais organizado e mais fácil de testar, assim, por esses motivos, acaba diminuindo a complexidade na fase de desenvolvimento além de oferecer facilidades na manutenção do estado da aplicação e depuração avançada.

Esse artigo descreve uma abordagem simples para começar a entender este novo padrão.

## Requisitos para a implementação
- Nível básico na construção de aplicações em iOS (Swift + Xcode).
- Conhecimento do padrão de projeto Observer.
- Saber utilizar o sistema de dependencias CocoaPods.

## Componentes

- **State:** Representa o estado da aplicação. Deve existir apenas um, podendo este ser dividido em sub-estados.
- **Actions:** São objetos simples que descrevem o que o sistema pode fazer. Esses objetos podem carregar informações ou não, dependendo do caso. Eles são despachados pela camada View como intenções de alterar o estado da aplicação.
- **Reducers:** É aqui que desenvolvemos a lógica principal da aplicação. Reducers devem ser funções puras[link], sem efeitos colaterais [link] e devem ser síncronos. São os únicos objetos que podem criar um novo estado para a aplicação. Eles recebem uma ação e o estado atual, e retornam um novo estado.

![imagem do fluxo](unidirectional_data_flow.png)

Vejam que o fluxo unidirecional acontece quando a View despacha uma Action. Essa Action é passada para o Reducer correspondente, então este Reducer gera um novo State de acordo com a Action passada, e o State é passado de volta para a View para que esta seja alterada.

- **Store:** É um dos componentes mais importantes dessa implementação. É ela que agrega todos os componentes citados acima e faz o fluxo funcionar. A View despacha uma nova Action para a Store. A Store então, passa essa Action para o Reducer junto com o State atual e então recebe de volta o novo State do Reducer. A View é avisada sempre que um novo State é criado, isso é possível pela implementação do padrão de projeto **Observer** que permite que a View vire "assinante" da Store, para ser notificada.

## Vamos começar
Minha abordagem para começarmos a aprender Redux é construir uma aplicação de exemplo - um jogo de "Pedra, Papel e Tesoura" -  utilizando uma biblioteca chamada ReSwift que implementa os conceitos dessa arquitetura em Swift.

Começamos então fazendo um esboço de como deve ser a aplicação. Para simplificar, a aplicação deverá funcionar em um único ViewController, contendo 3 botões na parte inferior (Pedra, Papel e Tesoura), 1 campo de mensagem na parte superior e 2 placeholders para mostrar quando um jogador já realizou sua jogada e no final para revelar a arma dos jogadores.

![imagem da view](initial_sketch.png)

Para começar o desenvolvimento propus um caso de uso em que o Jogador1 escolhe **Tesousa** e o Jogador2 escolhe **Pedra**, resultando na vitória do Jogador2. Esse fluxo aconteceria da seguinte forma:

![imagem da view](use_case_sketch.png)

## Desenvolvimento

Criamos um novo projeto no Xcode do tipo "Single view application" e habilitamos "Include Unit Tests" para podermos fazer um teste usando os conceitos de Redux.

Instale o pod ["ReSwift"](https://github.com/ReSwift/ReSwift), utilizando [CocoaPods](https://cocoapods.org/).

Em seguida vamos criar o primeiro componente, o **State**. Observando as imagens acima, conseguimos perceber claramente as partes do app que irão se alterar durante a execução, cada parte desta consiste no estado da aplicação. Criei então um arquivo `State.swift` e dentro dele coloquei as estruturas que formam o estado, juntamente com possíveis estruturas de modelo que formam o conceito da aplicação. É importante salientar que as estruturas devem ser imutáveis para que o Redux funcione, só assim garantimos que o State seja alterado apenas pelos Reducers, por isso utilizei Structs e Enums ao invés de Classes:

``` swift
import ReSwift

// MARK:- STATE

struct AppState: StateType {
    
    var message: Message
    var turn: Turn
    var player1Play: Play
    var player2Play: Play
    var result: Result?
    
    init() {
        
        self.message = .player1choose
        self.turn = Turn(player: .one)
        self.player1Play = Play(chosen: false, weapon: nil)
        self.player2Play = Play(chosen: false, weapon: nil)
    }
}


// MARK:- MODEL & OPTIONS

enum Message: String {
    
    case player1choose = "PLAYER 1 - Choose your weapon:"
    case player2choose = "PLAYER 2 - Choose your weapon:"
    case player1wins = "PLAYER 1 WINS!"
    case player2wins = "PLAYER 2 WINS!"
    case draw = "DRAW!"
}

struct Turn {
    
    var player: Player
}

enum Player {
    
    case one
    case two
}

struct Play {
    
    var chosen: Bool
    var weapon: Weapon?
}

enum Weapon: String {
    
    case rock = "Rock"
    case paper = "Paper"
    case scissors = "Scissors"
}

enum Result {
    
    case draw
    case player1wins
    case player2wins
}
```

Agora vamos criar uma Action, que será a descrição de uma ação que tem intenção de alterar o State. Neste caso temos apenas uma, ChooseWeaponAction, que é disparada quando cada jogador escolhe uma arma:

``` swift
import ReSwift

// MARK:- ACTIONS

struct ChooseWeaponAction: Action {
    
    var weapon: Weapon
}
```

Por último vamos construir o Reducer, aqui nós filtramos a Action criada, pegamos o State atual da aplicação e geramos um novo State baseado na lógica que desenvolveremos com as informações contidas na Action:


``` swift
import ReSwift

// MARK:- REDUCERS

func appReducer(action: Action, state: AppState?) -> AppState {
    
    // creates a new state if one does not already exist
    var state = state ?? AppState()
    
    switch action {
    case let chooseWeaponAction as ChooseWeaponAction:
        
        let turn = state.turn
        switch turn.player {
        case .one:
            
            // create a play
            let play = Play(chosen: true, weapon: chooseWeaponAction.weapon)
            state.player1Play = play
            
            // pass the turn to the next player
            state.turn = Turn(player: .two)
            
            // change the message
            state.message = .player2choose
            
        case .two:
            
            // create a play
            let play = Play(chosen: true, weapon: chooseWeaponAction.weapon)
            state.player2Play = play
            
            // calculate who won
            let player1weapon = state.player1Play.weapon ?? .rock
            let player2weapon = state.player2Play.weapon ?? .rock
            
            switch player1weapon {
            case .rock:
                switch player2weapon {
                case .rock:
                    state.result = .draw
                    state.message = .draw
                case .paper:
                    state.result = .player2wins
                    state.message = .player2wins
                case .scissors:
                    state.result = .player1wins
                    state.message = .player1wins
                }
            case .paper:
                switch player2weapon {
                case .rock:
                    state.result = .player1wins
                    state.message = .player1wins
                case .paper:
                    state.result = .draw
                    state.message = .draw
                case .scissors:
                    state.result = .player2wins
                    state.message = .player2wins
                }
            case .scissors:
                switch player2weapon {
                case .rock:
                    state.result = .player2wins
                    state.message = .player2wins
                case .paper:
                    state.result = .player1wins
                    state.message = .player1wins
                case .scissors:
                    state.result = .draw
                    state.message = .draw
                }
            }    
        }
        
    default:
        break
    }
    
    // return the new state
    return state
}
```

## Teste

Pronto, simples assim, nós implementamos um padrão Redux com fluxo unidirecional. Para mostrar a facilidade de testar esse tipo de arquitetura, construi esta classe de XCTest que testa lógicas da aplicação sem mesmo termos construído a UI (View).


``` swift
import XCTest
import ReSwift
@testable import ReduxPaperSwift

class ReduxPaperSwiftTests: XCTestCase {
    
    // testing whether a rule works.
    func test1() {
        
        let store = Store<AppState>(reducer: appReducer, state: nil)
        
        // Player 1 choose
        store.dispatch(ChooseWeaponAction(weapon: .rock))
        
        // Player 2 choose
        store.dispatch(ChooseWeaponAction(weapon: .scissors))
        
        // Check result
        XCTAssertEqual(store.state.result, .player1wins)
    }
    
    // testing whether another rule works.
    func test2() {
        
        let store = Store<AppState>(reducer: appReducer, state: nil)
        
        // Player 1 choose
        store.dispatch(ChooseWeaponAction(weapon: .rock))
        
        // Player 2 choose
        store.dispatch(ChooseWeaponAction(weapon: .paper))
        
        // Check result
        XCTAssertEqual(store.state.result, .player2wins)
    }
    
}
```

## Finalizando

Para finalizar, criei um ViewController com as características mostradas do desenho de esboço, e fiz esse ViewController se tornar um "assinante" da Store, podendo assim executar uma mudança nas views sempre que o State mudar. Isso acontece com a implementação do protocolo StoreSubscriber:

``` swift
import UIKit
import ReSwift

class ViewController: UIViewController, StoreSubscriber {

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var placeholder1: UILabel!
    @IBOutlet weak var placeholder2: UILabel!
    
    @IBAction func rockButton(_ sender: Any) {
        store.dispatch(ChooseWeaponAction(weapon: .rock))
    }
    
    @IBAction func paperButton(_ sender: Any) {
        store.dispatch(ChooseWeaponAction(weapon: .paper))
    }
    
    @IBAction func scissorsButton(_ sender: Any) {
        store.dispatch(ChooseWeaponAction(weapon: .scissors))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.subscribe(self)
    }
    
    func newState(state: AppState) {
        
        message.text = state.message.rawValue
        
        if state.player2Play.chosen {
            placeholder1.text = state.player1Play.weapon?.rawValue
            placeholder2.text = state.player2Play.weapon?.rawValue
        } else {
            placeholder1.text = state.player1Play.chosen ? "chosen" : ""
        }
    }
}
```

## Créditos
- [Redux](http://redux.js.org/)
- [ReSwift](https://github.com/ReSwift/ReSwift)


## Para se aprofundar no assunto
- [Tutorial de ReSwift do site Ray Wenderlich](https://www.raywenderlich.com/155815/reswift-tutorial-memory-game-app)
