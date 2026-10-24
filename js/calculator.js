/* ==========================================================================
   SHIFTLY - Real-Time Interactive Shift & Overtime Calculator Engine
   Calculates Israeli Labor Law Overtime Tiers & Shabbat Rates
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  const hourlyRateInput = document.getElementById('hourlyRate');
  const shiftHoursInput = document.getElementById('shiftHours');
  const shiftHoursVal = document.getElementById('shiftHoursVal');
  const breakMinutesInput = document.getElementById('breakMinutes');
  const shabbatToggle = document.getElementById('shabbatToggle');
  const tipsInput = document.getElementById('tipsInput');

  // Result element targets
  const regHoursVal = document.getElementById('resRegHours');
  const ot1HoursVal = document.getElementById('resOt1Hours');
  const ot2HoursVal = document.getElementById('resOt2Hours');
  const extraEarningsVal = document.getElementById('resExtraEarnings');
  const totalAmountVal = document.getElementById('resTotalAmount');

  if (!hourlyRateInput || !totalAmountVal) return;

  let currentAnimatedTotal = 0;

  function calculateShift() {
    const hourlyRate = parseFloat(hourlyRateInput.value) || 0;
    const totalShiftHours = parseFloat(shiftHoursInput.value) || 8;
    const breakHours = (parseFloat(breakMinutesInput ? breakMinutesInput.value : 0) || 0) / 60;
    const netHours = Math.max(0, totalShiftHours - breakHours);
    const isShabbat = shabbatToggle ? shabbatToggle.checked : false;
    const tipsAndExpenses = parseFloat(tipsInput ? tipsInput.value : 0) || 0;

    // Display shift hours slider value
    if (shiftHoursVal) {
      shiftHoursVal.textContent = `${totalShiftHours.toFixed(1)} שעות`;
    }

    let regHours = 0;
    let ot1Hours = 0; // 125% (or Shabbat 175%)
    let ot2Hours = 0; // 150% (or Shabbat 200%)

    // Israeli Labor Law Overtime Tier Logic
    if (netHours <= 8.0) {
      regHours = netHours;
    } else if (netHours <= 10.0) {
      regHours = 8.0;
      ot1Hours = netHours - 8.0;
    } else {
      regHours = 8.0;
      ot1Hours = 2.0;
      ot2Hours = netHours - 10.0;
    }

    // Rate Multipliers
    const regMultiplier = isShabbat ? 1.5 : 1.0;
    const ot1Multiplier = isShabbat ? 1.75 : 1.25;
    const ot2Multiplier = isShabbat ? 2.0 : 1.5;

    const regPay = regHours * hourlyRate * regMultiplier;
    const ot1Pay = ot1Hours * hourlyRate * ot1Multiplier;
    const ot2Pay = ot2Hours * hourlyRate * ot2Multiplier;

    const totalGross = regPay + ot1Pay + ot2Pay + tipsAndExpenses;

    // Update Text Fields
    if (regHoursVal) {
      regHoursVal.textContent = `${regHours.toFixed(1)} ש"ע (₪${regPay.toFixed(0)})`;
    }
    if (ot1HoursVal) {
      const ot1Label = isShabbat ? '175%' : '125%';
      ot1HoursVal.textContent = `${ot1Hours.toFixed(1)} ש"ע [${ot1Label}] (₪${ot1Pay.toFixed(0)})`;
    }
    if (ot2HoursVal) {
      const ot2Label = isShabbat ? '200%' : '150%';
      ot2HoursVal.textContent = `${ot2Hours.toFixed(1)} ש"ע [${ot2Label}] (₪${ot2Pay.toFixed(0)})`;
    }
    if (extraEarningsVal) {
      extraEarningsVal.textContent = `₪${tipsAndExpenses.toFixed(0)}`;
    }

    // Smooth Number Count Animation for Total Amount
    animateTotalAmount(totalGross);
  }

  function animateTotalAmount(targetTotal) {
    const startVal = currentAnimatedTotal;
    const duration = 400; // ms
    const startTime = performance.now();

    function updateStep(now) {
      const elapsed = now - startTime;
      const progress = Math.min(elapsed / duration, 1);
      // Ease out quad
      const easeProgress = 1 - (1 - progress) * (1 - progress);

      const current = startVal + (targetTotal - startVal) * easeProgress;
      currentAnimatedTotal = current;

      totalAmountVal.textContent = `₪${current.toFixed(2)}`;

      if (progress < 1) {
        requestAnimationFrame(updateStep);
      }
    }

    requestAnimationFrame(updateStep);
  }

  // Attach Event Listeners to Inputs
  const inputs = [
    hourlyRateInput, shiftHoursInput, breakMinutesInput, shabbatToggle, tipsInput
  ];

  inputs.forEach(input => {
    if (input) {
      input.addEventListener('input', calculateShift);
      input.addEventListener('change', calculateShift);
    }
  });

  // Initial Calculation
  calculateShift();
});
