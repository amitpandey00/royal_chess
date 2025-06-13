import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(ChessApp());
}

class ChessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Royal Chess',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: GameSetupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum PieceType { king, queen, rook, bishop, knight, pawn }

enum PieceColor { white, black }

enum OpponentType { manual, robot }

class GameConfiguration {
  final PieceColor playerColor;
  final OpponentType opponentType;

  GameConfiguration({
    required this.playerColor,
    required this.opponentType,
  });
}

class ChessPiece {
  final PieceType type;
  final PieceColor color;
  bool hasMoved;

  ChessPiece({required this.type, required this.color, this.hasMoved = false});

  String get symbol {
    const symbols = {
      PieceType.king: {'white': '♔', 'black': '♚'},
      PieceType.queen: {'white': '♕', 'black': '♛'},
      PieceType.rook: {'white': '♖', 'black': '♜'},
      PieceType.bishop: {'white': '♗', 'black': '♝'},
      PieceType.knight: {'white': '♘', 'black': '♞'},
      PieceType.pawn: {'white': '♙', 'black': '♟'},
    };
    return symbols[type]![color.name]!;
  }
}

class Position {
  final int row;
  final int col;

  Position(this.row, this.col);

  @override
  bool operator ==(Object other) => identical(this, other) || other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  bool isValid() => row >= 0 && row < 8 && col >= 0 && col < 8;
}

class GameSetupScreen extends StatefulWidget {
  @override
  _GameSetupScreenState createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> with TickerProviderStateMixin {
  PieceColor selectedPlayerColor = PieceColor.white;
  OpponentType selectedOpponentType = OpponentType.manual;

  late AnimationController _backgroundController;
  late Animation<double> _backgroundRotation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _backgroundRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _startGame() {
    GameConfiguration config = GameConfiguration(
      playerColor: selectedPlayerColor,
      opponentType: selectedOpponentType,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ChessGame(configuration: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundRotation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center +
                    Alignment(
                      0.3 * math.sin(_backgroundRotation.value),
                      0.3 * math.cos(_backgroundRotation.value),
                    ),
                radius: 1.2,
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f3460),
                  Color(0xFF533483),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    _buildTitle(),
                    SizedBox(height: 40),
                    _buildColorSelection(),
                    SizedBox(height: 30),
                    _buildOpponentSelection(),
                    SizedBox(height: 40),
                    _buildStartButton(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          '♔ ROYAL CHESS ♛',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 4,
            shadows: [
              Shadow(
                offset: Offset(0, 3),
                blurRadius: 6,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'GAME SETUP',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        children: [
          Text(
            'CHOOSE YOUR COLOR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildColorOption(
                  color: PieceColor.white,
                  label: 'WHITE',
                  icon: '♔',
                  isSelected: selectedPlayerColor == PieceColor.white,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildColorOption(
                  color: PieceColor.black,
                  label: 'BLACK',
                  icon: '♚',
                  isSelected: selectedPlayerColor == PieceColor.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption({
    required PieceColor color,
    required String label,
    required String icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlayerColor = color;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: color == PieceColor.white ? [Colors.white, Colors.grey[200]!] : [Colors.grey[800]!, Colors.black],
                )
              : LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? (color == PieceColor.white ? Colors.white : Colors.grey[600]!) : Colors.white30,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 32,
                color: isSelected ? (color == PieceColor.white ? Colors.black : Colors.white) : Colors.white70,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? (color == PieceColor.white ? Colors.black : Colors.white) : Colors.white70,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpponentSelection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        children: [
          Text(
            'CHOOSE OPPONENT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildOpponentOption(
                  type: OpponentType.manual,
                  label: 'MANUAL',
                  subtitle: 'Human vs Human',
                  icon: Icons.people,
                  isSelected: selectedOpponentType == OpponentType.manual,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildOpponentOption(
                  type: OpponentType.robot,
                  label: 'ROBOT',
                  subtitle: 'Human vs AI',
                  icon: Icons.smart_toy,
                  isSelected: selectedOpponentType == OpponentType.robot,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentOption({
    required OpponentType type,
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOpponentType = type;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                )
              : LinearGradient(
                  colors: [Colors.transparent, Colors.transparent],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white30,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.white70,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white70 : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: _startGame,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'START GAME',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChessGame extends StatefulWidget {
  final GameConfiguration configuration;

  ChessGame({required this.configuration});

  @override
  _ChessGameState createState() => _ChessGameState();
}

class _ChessGameState extends State<ChessGame> with TickerProviderStateMixin {
  List<List<ChessPiece?>> board = List.generate(8, (i) => List.filled(8, null));
  PieceColor currentPlayer = PieceColor.white;
  Position? selectedPosition;
  List<Position> validMoves = [];
  String gameStatus = '';
  late GameConfiguration gameConfig;
  bool isRobotThinking = false;

  late AnimationController _boardAnimationController;
  late AnimationController _pieceAnimationController;
  late AnimationController _backgroundController;
  late Animation<double> _boardAnimation;
  late Animation<double> _pieceScaleAnimation;
  late Animation<double> _backgroundRotation;

  @override
  void initState() {
    super.initState();
    gameConfig = widget.configuration;

    // Set initial player based on configuration
    if (gameConfig.playerColor == PieceColor.black) {
      currentPlayer = PieceColor.white; // Start with white, but player plays black
    }

    initializeBoard();
    _setupAnimations();

    // If robot is playing and it's robot's turn, make robot move
    _checkRobotMove();
  }

  void _setupAnimations() {
    _boardAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _pieceAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _boardAnimation = CurvedAnimation(
      parent: _boardAnimationController,
      curve: Curves.elasticOut,
    );

    _pieceScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pieceAnimationController,
      curve: Curves.elasticOut,
    ));

    _backgroundRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundController);

    _boardAnimationController.forward();
  }

  @override
  void dispose() {
    _boardAnimationController.dispose();
    _pieceAnimationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void initializeBoard() {
    // Initialize pawns
    for (int i = 0; i < 8; i++) {
      board[1][i] = ChessPiece(type: PieceType.pawn, color: PieceColor.black);
      board[6][i] = ChessPiece(type: PieceType.pawn, color: PieceColor.white);
    }

    // Initialize other pieces
    List<PieceType> backRow = [PieceType.rook, PieceType.knight, PieceType.bishop, PieceType.queen, PieceType.king, PieceType.bishop, PieceType.knight, PieceType.rook];

    for (int i = 0; i < 8; i++) {
      board[0][i] = ChessPiece(type: backRow[i], color: PieceColor.black);
      board[7][i] = ChessPiece(type: backRow[i], color: PieceColor.white);
    }
  }

  List<Position> getValidMoves(Position pos) {
    ChessPiece? piece = board[pos.row][pos.col];
    if (piece == null) return [];

    List<Position> moves = [];

    switch (piece.type) {
      case PieceType.pawn:
        moves = getPawnMoves(pos, piece);
        break;
      case PieceType.rook:
        moves = getRookMoves(pos, piece);
        break;
      case PieceType.bishop:
        moves = getBishopMoves(pos, piece);
        break;
      case PieceType.queen:
        moves = getQueenMoves(pos, piece);
        break;
      case PieceType.king:
        moves = getKingMoves(pos, piece);
        break;
      case PieceType.knight:
        moves = getKnightMoves(pos, piece);
        break;
    }

    return moves.where((move) => move.isValid()).toList();
  }

  List<Position> getPawnMoves(Position pos, ChessPiece piece) {
    List<Position> moves = [];
    int direction = piece.color == PieceColor.white ? -1 : 1;
    int startRow = piece.color == PieceColor.white ? 6 : 1;

    Position forward = Position(pos.row + direction, pos.col);
    if (forward.isValid() && board[forward.row][forward.col] == null) {
      moves.add(forward);

      if (pos.row == startRow) {
        Position doubleForward = Position(pos.row + 2 * direction, pos.col);
        if (doubleForward.isValid() && board[doubleForward.row][doubleForward.col] == null) {
          moves.add(doubleForward);
        }
      }
    }

    for (int colOffset in [-1, 1]) {
      Position diagonal = Position(pos.row + direction, pos.col + colOffset);
      if (diagonal.isValid()) {
        ChessPiece? target = board[diagonal.row][diagonal.col];
        if (target != null && target.color != piece.color) {
          moves.add(diagonal);
        }
      }
    }

    return moves;
  }

  List<Position> getRookMoves(Position pos, ChessPiece piece) {
    List<Position> moves = [];
    List<List<int>> directions = [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0]
    ];

    for (List<int> dir in directions) {
      for (int i = 1; i < 8; i++) {
        Position newPos = Position(pos.row + dir[0] * i, pos.col + dir[1] * i);
        if (!newPos.isValid()) break;

        ChessPiece? target = board[newPos.row][newPos.col];
        if (target == null) {
          moves.add(newPos);
        } else {
          if (target.color != piece.color) {
            moves.add(newPos);
          }
          break;
        }
      }
    }

    return moves;
  }

  List<Position> getBishopMoves(Position pos, ChessPiece piece) {
    List<Position> moves = [];
    List<List<int>> directions = [
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1]
    ];

    for (List<int> dir in directions) {
      for (int i = 1; i < 8; i++) {
        Position newPos = Position(pos.row + dir[0] * i, pos.col + dir[1] * i);
        if (!newPos.isValid()) break;

        ChessPiece? target = board[newPos.row][newPos.col];
        if (target == null) {
          moves.add(newPos);
        } else {
          if (target.color != piece.color) {
            moves.add(newPos);
          }
          break;
        }
      }
    }

    return moves;
  }

  List<Position> getQueenMoves(Position pos, ChessPiece piece) {
    return [...getRookMoves(pos, piece), ...getBishopMoves(pos, piece)];
  }

  List<Position> getKingMoves(Position pos, ChessPiece piece) {
    List<Position> moves = [];
    List<List<int>> directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1]
    ];

    for (List<int> dir in directions) {
      Position newPos = Position(pos.row + dir[0], pos.col + dir[1]);
      if (newPos.isValid()) {
        ChessPiece? target = board[newPos.row][newPos.col];
        if (target == null || target.color != piece.color) {
          moves.add(newPos);
        }
      }
    }

    return moves;
  }

  List<Position> getKnightMoves(Position pos, ChessPiece piece) {
    List<Position> moves = [];
    List<List<int>> knightMoves = [
      [-2, -1],
      [-2, 1],
      [-1, -2],
      [-1, 2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1]
    ];

    for (List<int> move in knightMoves) {
      Position newPos = Position(pos.row + move[0], pos.col + move[1]);
      if (newPos.isValid()) {
        ChessPiece? target = board[newPos.row][newPos.col];
        if (target == null || target.color != piece.color) {
          moves.add(newPos);
        }
      }
    }

    return moves;
  }

  void onSquareTapped(int row, int col) {
    // Don't allow moves if robot is thinking or if it's not player's turn in robot mode
    if (isRobotThinking) return;
    if (gameConfig.opponentType == OpponentType.robot && currentPlayer != gameConfig.playerColor) return;

    Position tappedPos = Position(row, col);

    if (selectedPosition == null) {
      ChessPiece? piece = board[row][col];
      if (piece != null && piece.color == currentPlayer) {
        setState(() {
          selectedPosition = tappedPos;
          validMoves = getValidMoves(tappedPos);
        });
        _pieceAnimationController.forward().then((_) {
          _pieceAnimationController.reverse();
        });
      }
    } else {
      if (validMoves.contains(tappedPos)) {
        ChessPiece? piece = board[selectedPosition!.row][selectedPosition!.col];
        if (piece != null) {
          setState(() {
            board[row][col] = piece;
            board[selectedPosition!.row][selectedPosition!.col] = null;
            piece.hasMoved = true;

            currentPlayer = currentPlayer == PieceColor.white ? PieceColor.black : PieceColor.white;

            selectedPosition = null;
            validMoves = [];

            updateGameStatus();
          });

          // Check if robot should move next
          _checkRobotMove();
        }
      } else {
        ChessPiece? piece = board[row][col];
        if (piece != null && piece.color == currentPlayer) {
          setState(() {
            selectedPosition = tappedPos;
            validMoves = getValidMoves(tappedPos);
          });
          _pieceAnimationController.forward().then((_) {
            _pieceAnimationController.reverse();
          });
        } else {
          setState(() {
            selectedPosition = null;
            validMoves = [];
          });
        }
      }
    }
  }

  void updateGameStatus() {
    if (gameConfig.opponentType == OpponentType.robot) {
      bool isPlayerTurn = currentPlayer == gameConfig.playerColor;
      if (isPlayerTurn) {
        gameStatus = 'Your turn (${currentPlayer.name.toUpperCase()})';
      } else {
        gameStatus = isRobotThinking ? 'Robot is thinking...' : 'Robot\'s turn (${currentPlayer.name.toUpperCase()})';
      }
    } else {
      gameStatus = 'Current turn: ${currentPlayer.name.toUpperCase()}';
    }
  }

  void _checkRobotMove() {
    if (gameConfig.opponentType == OpponentType.robot && currentPlayer != gameConfig.playerColor && !isRobotThinking) {
      _makeRobotMove();
    }
  }

  void _makeRobotMove() async {
    setState(() {
      isRobotThinking = true;
      updateGameStatus();
    });

    // Add delay to simulate thinking
    await Future.delayed(Duration(milliseconds: 1000 + math.Random().nextInt(1500)));

    List<Map<String, dynamic>> allPossibleMoves = [];

    // Find all possible moves for the robot
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];
        if (piece != null && piece.color == currentPlayer) {
          Position from = Position(row, col);
          List<Position> moves = getValidMoves(from);
          for (Position to in moves) {
            allPossibleMoves.add({
              'from': from,
              'to': to,
              'piece': piece,
              'capturedPiece': board[to.row][to.col],
            });
          }
        }
      }
    }

    if (allPossibleMoves.isNotEmpty) {
      // Simple AI: prioritize captures, then random moves
      allPossibleMoves.sort((a, b) {
        // Prioritize captures
        bool aCaptures = a['capturedPiece'] != null;
        bool bCaptures = b['capturedPiece'] != null;

        if (aCaptures && !bCaptures) return -1;
        if (!aCaptures && bCaptures) return 1;

        // If both capture or both don't capture, prioritize by piece value
        if (aCaptures && bCaptures) {
          int aValue = _getPieceValue(a['capturedPiece']);
          int bValue = _getPieceValue(b['capturedPiece']);
          return bValue.compareTo(aValue);
        }

        return 0;
      });

      // Select from top moves with some randomness
      int maxIndex = math.min(3, allPossibleMoves.length);
      Map<String, dynamic> selectedMove = allPossibleMoves[math.Random().nextInt(maxIndex)];

      Position from = selectedMove['from'];
      Position to = selectedMove['to'];

      setState(() {
        // Make the move
        board[to.row][to.col] = board[from.row][from.col];
        board[from.row][from.col] = null;
        board[to.row][to.col]!.hasMoved = true;

        currentPlayer = currentPlayer == PieceColor.white ? PieceColor.black : PieceColor.white;
        isRobotThinking = false;
        updateGameStatus();
      });
    } else {
      setState(() {
        isRobotThinking = false;
        updateGameStatus();
      });
    }
  }

  int _getPieceValue(ChessPiece? piece) {
    if (piece == null) return 0;
    switch (piece.type) {
      case PieceType.pawn:
        return 1;
      case PieceType.knight:
        return 3;
      case PieceType.bishop:
        return 3;
      case PieceType.rook:
        return 5;
      case PieceType.queen:
        return 9;
      case PieceType.king:
        return 100;
    }
  }

  void resetGame() {
    setState(() {
      board = List.generate(8, (i) => List.filled(8, null));
      currentPlayer = PieceColor.white;
      selectedPosition = null;
      validMoves = [];
      gameStatus = '';
      isRobotThinking = false;

      // Reset player based on configuration
      if (gameConfig.playerColor == PieceColor.black) {
        currentPlayer = PieceColor.white; // Start with white, but player plays black
      }

      initializeBoard();
      updateGameStatus();
    });
    _boardAnimationController.reset();
    _boardAnimationController.forward();

    // Check if robot should move first
    _checkRobotMove();
  }

  void _backToSetup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameSetupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundRotation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center +
                    Alignment(
                      0.3 * math.sin(_backgroundRotation.value),
                      0.3 * math.cos(_backgroundRotation.value),
                    ),
                radius: 1.2,
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f3460),
                  Color(0xFF533483),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildGameBoard()),
                  _buildControls(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            '♔ ROYAL CHESS ♛',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: currentPlayer == PieceColor.white ? [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)] : [Colors.grey[800]!.withOpacity(0.3), Colors.grey[800]!.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: currentPlayer == PieceColor.white ? Colors.white : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  currentPlayer == PieceColor.white ? Icons.wb_sunny : Icons.nightlight_round,
                  color: currentPlayer == PieceColor.white ? Colors.white : Colors.grey[300],
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  '${currentPlayer.name.toUpperCase()}\'S TURN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: currentPlayer == PieceColor.white ? Colors.white : Colors.grey[300],
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Center(
      child: AnimatedBuilder(
        animation: _boardAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _boardAnimation.value,
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF8B4513),
                          Color(0xFF654321),
                          Color(0xFF4A2C17),
                        ],
                      ),
                    ),
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      itemCount: 64,
                      itemBuilder: (context, index) {
                        int row = index ~/ 8;
                        int col = index % 8;
                        return _buildChessSquare(row, col);
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChessSquare(int row, int col) {
    bool isLightSquare = (row + col) % 2 == 0;
    bool isSelected = selectedPosition?.row == row && selectedPosition?.col == col;
    bool isValidMove = validMoves.contains(Position(row, col));
    ChessPiece? piece = board[row][col];

    return GestureDetector(
      onTap: () => onSquareTapped(row, col),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? RadialGradient(
                  colors: [
                    Colors.blue[300]!,
                    Colors.blue[500]!,
                  ],
                )
              : isValidMove
                  ? RadialGradient(
                      colors: [
                        Colors.green[300]!.withOpacity(0.8),
                        Colors.green[500]!.withOpacity(0.6),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isLightSquare ? [Color(0xFFF0D9B5), Color(0xFFE8D1A8)] : [Color(0xFFB58863), Color(0xFFA67C52)],
                    ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected || isValidMove
              ? [
                  BoxShadow(
                    color: (isSelected ? Colors.blue : Colors.green).withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
        ),
        child: Stack(
          children: [
            if (piece != null) _buildChessPiece(piece, isSelected),
            if (isValidMove && piece == null) _buildMoveIndicator(),
            if (isValidMove && piece != null) _buildCaptureIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildChessPiece(ChessPiece piece, bool isSelected) {
    return AnimatedBuilder(
      animation: isSelected ? _pieceScaleAnimation : kAlwaysCompleteAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _pieceScaleAnimation.value : 1.0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: piece.color == PieceColor.white ? [Colors.white, Colors.grey[200]!] : [Colors.grey[800]!, Colors.black],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  piece.symbol,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: piece.color == PieceColor.white ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoveIndicator() {
    return Center(
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.green[400]!,
              Colors.green[600]!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureIndicator() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red[500]!,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.refresh,
                label: 'NEW GAME',
                onPressed: resetGame,
                gradient: LinearGradient(
                  colors: [Colors.purple[400]!, Colors.purple[600]!],
                ),
              ),
              _buildControlButton(
                icon: Icons.clear,
                label: 'CLEAR',
                onPressed: () {
                  if (!isRobotThinking) {
                    setState(() {
                      selectedPosition = null;
                      validMoves = [];
                    });
                  }
                },
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.orange[600]!],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildControlButton(
            icon: Icons.settings,
            label: 'BACK TO SETUP',
            onPressed: _backToSetup,
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
