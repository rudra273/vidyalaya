import 'package:flutter/material.dart';
import '../../data/models/learn_assist.dart';

/// Lifecycle of an AI agent surface.
/// - [live]: fully working (talks to the backend).
/// - [mock]: a UI preview only — no backend yet (e.g. the AI Tutor mockup).
/// - [comingSoon]: announced but not yet usable.
enum AgentStatus { live, mock, comingSoon }

/// A single AI agent the student can pick from in the Learn AI hub.
///
/// Agents are declared as *data* (see [learnAgents]) so a future agent ships as
/// one entry here — not a new screen or a navigation change. The hub renders the
/// list and routes by [status]: [AgentStatus.live] opens the real chat with
/// [channel]; [AgentStatus.mock] opens its [mockRoute].
class LearnAgent {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final AgentStatus status;

  /// Backend channel for a [AgentStatus.live] agent (a [LearnAssistChannel]).
  final String? channel;

  /// Route to a [AgentStatus.mock] agent's preview screen.
  final String? mockRoute;

  const LearnAgent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    this.channel,
    this.mockRoute,
  });
}

/// The ordered list of AI agents shown in the Learn AI hub. Q&A is live today;
/// the Tutor is a mock preview until the real agent ships.
const learnAgents = <LearnAgent>[
  LearnAgent(
    id: 'qa',
    title: 'Q&A',
    subtitle: 'Ask anything from your textbooks',
    icon: Icons.auto_awesome,
    status: AgentStatus.live,
    channel: LearnAssistChannel.learnAssist,
  ),
  LearnAgent(
    id: 'tutor',
    title: 'AI Tutor',
    subtitle: 'Step-by-step guided lessons for each subject',
    icon: Icons.school_rounded,
    status: AgentStatus.mock,
    mockRoute: '/learn-ai/tutor',
  ),
];
