// ============================================================================
// IDLEMAN v16.0 - PRACTICE SCREEN (Level 2)
// ============================================================================
// File: lib/features/defense/screens/practice_screen.dart
// Purpose: Mindful tasks to earn extended access
// Philosophy: Investment through effort, not just time
// ============================================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idleman/core/theme/therapy_theme.dart';
import 'package:idleman/features/defense/providers/defense_provider.dart';

// ============================================================================
// PRACTICE SCREEN
// ============================================================================
class PracticeScreen extends ConsumerStatefulWidget {
  final String appName;
  final PracticeTask task;

  const PracticeScreen({
    super.key,
    required this.appName,
    required this.task,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  // -------------------------------------------------------------------------
  // MATH TASK STATE
  // -------------------------------------------------------------------------
  int _firstNumber = 0;
  int _secondNumber = 0;
  String _operator = '+';
  int _correctAnswer = 0;
  String _userInput = '';
  bool? _lastAnswerCorrect;

  @override
  void initState() {
    super.initState();
    debugPrint('[PracticeScreen::initState] Task: ${widget.task}');

    if (widget.task == PracticeTask.focusActivation) {
      _generateMathProblem();
    }
  }

  void _generateMathProblem() {
    debugPrint('[PracticeScreen::_generateMathProblem] Generating new problem.');

    final random = Random();
    
    // Generate appropriate difficulty
    _firstNumber = random.nextInt(20) + 5; // 5-24
    _secondNumber = random.nextInt(15) + 3; // 3-17
    
    // Random operator
    final operators = ['+', '-', '×'];
    _operator = operators[random.nextInt(operators.length)];

    // Calculate answer
    switch (_operator) {
      case '+':
        _correctAnswer = _firstNumber + _secondNumber;
        break;
      case '-':
        // Ensure positive result
        if (_firstNumber < _secondNumber) {
          final temp = _firstNumber;
          _firstNumber = _secondNumber;
          _secondNumber = temp;
        }
        _correctAnswer = _firstNumber - _secondNumber;
        break;
      case '×':
        // Smaller numbers for multiplication
        _firstNumber = random.nextInt(10) + 2;
        _secondNumber = random.nextInt(8) + 2;
        _correctAnswer = _firstNumber * _secondNumber;
        break;
    }

    _userInput = '';
    _lastAnswerCorrect = null;

    debugPrint('[PracticeScreen] Problem: $_firstNumber $_operator $_secondNumber = $_correctAnswer');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[PracticeScreen::build] Building practice UI.');

    final defenseState = ref.watch(defenseProvider);

    return Scaffold(
      backgroundColor: TherapyColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 32),

              // Progress indicator
              _buildProgressIndicator(defenseState),
              const SizedBox(height: 40),

              // Task content
              Expanded(
                child: widget.task == PracticeTask.mindfulWalk
                    ? _buildWalkTask(defenseState)
                    : _buildMathTask(defenseState),
              ),

              // Cancel button
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // HEADER
  // -------------------------------------------------------------------------
  Widget _buildHeader() {
    debugPrint('[PracticeScreen::_buildHeader] Building header.');

    return Column(
      children: [
        Text(
          widget.task == PracticeTask.mindfulWalk
              ? 'Mindful Walk'
              : 'Focus Activation',
          style: TherapyText.heading1(),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete this practice to continue using ${widget.appName}',
          style: TherapyText.body().copyWith(
            color: TherapyColors.graphite,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // PROGRESS INDICATOR
  // -------------------------------------------------------------------------
  Widget _buildProgressIndicator(DefenseState state) {
    debugPrint('[PracticeScreen::_buildProgressIndicator] Building progress.');

    final progress = widget.task == PracticeTask.mindfulWalk
        ? state.stepProgress
        : state.mathProgress;

    final label = widget.task == PracticeTask.mindfulWalk
        ? '${state.stepsTaken} / ${state.targetSteps} steps'
        : '${state.mathProblemsCompleted} / ${state.mathProblemsTotal} problems';

    return Column(
      children: [
        // Progress bar
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: TherapyColors.graphite.withOpacity(0.15),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Stack(
            children: [
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TherapyColors.growth,
                        TherapyColors.growth.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TherapyText.body().copyWith(
            color: TherapyColors.graphite,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // WALK TASK
  // -------------------------------------------------------------------------
  Widget _buildWalkTask(DefenseState state) {
    debugPrint('[PracticeScreen::_buildWalkTask] Building walk task.');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Walking illustration
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: TherapyColors.growth.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.directions_walk_rounded,
            size: 100,
            color: TherapyColors.growth,
          ),
        ),
        const SizedBox(height: 32),

        // Step count
        Text(
          '${state.stepsTaken}',
          style: TherapyText.heading1().copyWith(
            fontSize: 72,
            color: TherapyColors.growth,
          ),
        ),
        Text(
          'steps taken',
          style: TherapyText.body().copyWith(
            color: TherapyColors.graphite,
          ),
        ),

        // Jerk warning
        if (state.jerkDetected) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: TherapyColors.boundary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TherapyColors.boundary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: TherapyColors.boundary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Movement too chaotic. Walk naturally.',
                  style: TherapyText.caption().copyWith(
                    color: TherapyColors.boundary,
                  ),
                ),
              ],
            ),
          ),
        ],

        const Spacer(),

        // Instructions
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TherapyColors.surface,
            borderRadius: TherapyShapes.cardBorderRadius(),
            boxShadow: TherapyShadows.card(),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: TherapyColors.graphite,
                size: 24,
              ),
              const SizedBox(height: 12),
              Text(
                'Walk around naturally. Shaking the phone won\'t work!',
                style: TherapyText.body().copyWith(
                  color: TherapyColors.graphite,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // MATH TASK
  // -------------------------------------------------------------------------
  Widget _buildMathTask(DefenseState state) {
    debugPrint('[PracticeScreen::_buildMathTask] Building math task.');

    return Column(
      children: [
        const SizedBox(height: 20),

        // Math problem card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: TherapyColors.surface,
            borderRadius: TherapyShapes.cardBorderRadius(),
            boxShadow: TherapyShadows.card(),
            border: _lastAnswerCorrect == false
                ? Border.all(color: TherapyColors.boundary, width: 2)
                : _lastAnswerCorrect == true
                    ? Border.all(color: TherapyColors.growth, width: 2)
                    : null,
          ),
          child: Column(
            children: [
              // Problem
              Text(
                '$_firstNumber $_operator $_secondNumber = ?',
                style: TherapyText.heading1().copyWith(
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 24),

              // Answer display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: TherapyColors.canvas,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: TherapyColors.graphite.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  _userInput.isEmpty ? ' ' : _userInput,
                  style: TherapyText.heading2().copyWith(
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Feedback
              if (_lastAnswerCorrect != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _lastAnswerCorrect! ? 'Correct! ✓' : 'Try again',
                    style: TherapyText.body().copyWith(
                      color: _lastAnswerCorrect!
                          ? TherapyColors.growth
                          : TherapyColors.boundary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const Spacer(),

        // Numpad
        _buildNumpad(),
      ],
    );
  }

  Widget _buildNumpad() {
    debugPrint('[PracticeScreen::_buildNumpad] Building numpad.');

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TherapyColors.surface,
        borderRadius: TherapyShapes.cardBorderRadius(),
      ),
      child: Column(
        children: [
          Row(children: [
            _buildNumpadButton('1'),
            _buildNumpadButton('2'),
            _buildNumpadButton('3'),
          ]),
          Row(children: [
            _buildNumpadButton('4'),
            _buildNumpadButton('5'),
            _buildNumpadButton('6'),
          ]),
          Row(children: [
            _buildNumpadButton('7'),
            _buildNumpadButton('8'),
            _buildNumpadButton('9'),
          ]),
          Row(children: [
            _buildNumpadButton('C', isAction: true),
            _buildNumpadButton('0'),
            _buildNumpadButton('✓', isAction: true, isSubmit: true),
          ]),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(String label, {bool isAction = false, bool isSubmit = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: isSubmit
              ? TherapyColors.growth
              : isAction
                  ? TherapyColors.graphite.withOpacity(0.1)
                  : TherapyColors.canvas,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _handleNumpadPress(label),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 64,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TherapyText.heading2().copyWith(
                  color: isSubmit ? TherapyColors.surface : TherapyColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleNumpadPress(String label) {
    debugPrint('[PracticeScreen::_handleNumpadPress] Pressed: $label');
    HapticFeedback.lightImpact();

    setState(() {
      if (label == 'C') {
        // Clear
        _userInput = '';
        _lastAnswerCorrect = null;
      } else if (label == '✓') {
        // Submit
        _checkAnswer();
      } else {
        // Add digit (max 4 digits)
        if (_userInput.length < 4) {
          _userInput += label;
        }
      }
    });
  }

  void _checkAnswer() {
    debugPrint('[PracticeScreen::_checkAnswer] Checking: $_userInput == $_correctAnswer');

    final userAnswer = int.tryParse(_userInput);
    
    if (userAnswer == _correctAnswer) {
      debugPrint('[PracticeScreen] Correct!');
      setState(() => _lastAnswerCorrect = true);
      HapticFeedback.mediumImpact();

      // Notify provider
      ref.read(defenseProvider.notifier).completeMathProblem();

      // Generate next problem after delay
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          final state = ref.read(defenseProvider);
          if (!state.isMathTaskComplete) {
            setState(() {
              _generateMathProblem();
            });
          } else {
            // Task complete - navigate back
            Navigator.of(context).pop(true);
          }
        }
      });
    } else {
      debugPrint('[PracticeScreen] Incorrect!');
      setState(() => _lastAnswerCorrect = false);
      HapticFeedback.heavyImpact();

      // Clear input after delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _userInput = '';
            _lastAnswerCorrect = null;
          });
        }
      });
    }
  }

  // -------------------------------------------------------------------------
  // CANCEL BUTTON
  // -------------------------------------------------------------------------
  Widget _buildCancelButton() {
    debugPrint('[PracticeScreen::_buildCancelButton] Building cancel option.');

    return TextButton(
      onPressed: () {
        debugPrint('[PracticeScreen] Cancel tapped.');
        HapticFeedback.lightImpact();
        ref.read(defenseProvider.notifier).cancel();
        Navigator.of(context).pop(false);
      },
      child: Text(
        'Go back instead',
        style: TherapyText.body().copyWith(
          color: TherapyColors.graphite,
        ),
      ),
    );
  }
}
