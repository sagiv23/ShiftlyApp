# Cross-Platform Adaptive UI/UX Refactoring Plan

This plan outlines the adaptation of the Shiftly app across all platforms (Mobile, Tablet, Desktop) with responsive navigation and platform-tailored interactions.

## User Review Required

> [!IMPORTANT]
> **Adaptive Navigation Structure**:
> - **Mobile (< 768px)**: Bottom Navigation Bar + Navigation Drawer (Side Menu) for secondary/all routes.
> - **Desktop / Wide Screen (>= 768px)**: Top Navigation Bar.
> - **Collapsed Desktop / Tablet**: If a desktop or wide window is resized below 768px width, the top bar smoothly transitions/collapses into a Navigation Drawer (Side Menu).
>
> **Interaction Model (Swipe vs. Buttons)**:
> - **Mobile**: Swipe gestures (`Dismissible`) for quick actions (Edit/Delete).
> - **Wide Screens (>= 768px)**: Visible action buttons (Edit & Delete icons) directly in list items instead of requiring a swipe gesture, improving desktop usability.

## Proposed Changes

### Navigation & Shell

#### [NEW] [adaptive_scaffold.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/widgets/adaptive_scaffold.dart)
- Create a reusable adaptive scaffold widget that detects screen width and viewport type.
- Manages Top Navigation Bar (desktop), Bottom Navigation Bar (mobile), and Navigation Drawer (side menu for mobile & resized desktop).
- Handles responsive breakpoint switching (breakpoint at ~768px).

### Screen Adaptations (Swipe vs. Buttons & Layout)

#### [MODIFY] [home_screen.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/screens/home_screen.dart)
- Integrate `AdaptiveScaffold` or responsive layout wrapper.
- Replace `Dismissible` shift items with conditional layout: `Dismissible` on mobile, row of action buttons (Edit/Delete) on wide screens (>= 768px).

#### [MODIFY] [calendar_screen.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/screens/calendar_screen.dart)
- Make calendar view and shift item list responsive.
- Replace `Dismissible` with action buttons on wide screens.

#### [MODIFY] [expenses_screen.dart](file:///C:/Users/sagiv/Desktop/Shiftly/lib/screens/expenses_screen.dart)
- Make expense items responsive (swap `Dismissible` for action buttons on wide screens).

## Verification Plan

### Automated Tests
- Run existing unit tests (`flutter test`) to ensure business logic remains intact.
- Add widget tests for responsive breakpoints and adaptive scaffold behavior if feasible.

### Manual Verification
- Test app on mobile screen dimensions (verifying bottom navigation bar and side drawer menu).
- Test app on desktop window sizes (verifying top menu bar, and resizing window below 768px to verify transition to side menu).
- Verify list items show swipe gestures on mobile and visible action buttons on wide screens.
