type CoreNumbers = {
  life_path: number;
  expression: number;
  soul_urge: number;
  personality: number;
  birthday: number;
  attitude: number;
  maturity: number;
};

type PeakChallenge = {
  first: number;
  second: number;
  third: number;
  fourth: number;
};

export type NumerologyBaseline = {
  calc_version: string;
  generated_at: string;
  input: {
    full_name: string;
    birth_date: string;
    normalized_name: string;
  };
  core_numbers: CoreNumbers;
  psych_matrix: {
    digit_counts: Record<string, number>;
    dominant_digits: number[];
    missing_digits: number[];
    total_energy_score: number;
  };
  cycle_markers: {
    peaks: PeakChallenge;
    challenges: PeakChallenge;
  };
};

const MASTER_NUMBERS = new Set<number>([11, 22, 33]);
const VOWELS = new Set<string>(["A", "E", "I", "O", "U", "Y"]);

function digitSum(value: number): number {
  return value
    .toString()
    .split("")
    .map((d) => Number(d))
    .reduce((acc, curr) => acc + curr, 0);
}

function reduceNumber(value: number, allowMaster = true): number {
  let n = Math.abs(Math.trunc(value));
  if (n === 0) return 0;
  while (n > 9 && !(allowMaster && MASTER_NUMBERS.has(n))) {
    n = digitSum(n);
  }
  return n;
}

function pythagoreanValue(letter: string): number {
  const code = letter.charCodeAt(0);
  if (code < 65 || code > 90) return 0;
  return ((code - 65) % 9) + 1;
}

function normalizeName(rawName: string): string {
  return rawName
    .trim()
    .toUpperCase()
    .replace(/Đ/g, "D")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^A-Z\s]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function normalizeBirthDate(rawBirthDate: string): string {
  const normalized = rawBirthDate.trim().slice(0, 10);
  const date = new Date(`${normalized}T00:00:00Z`);
  if (Number.isNaN(date.getTime())) {
    throw new Error("Invalid birth_date format. Expected YYYY-MM-DD.");
  }
  return normalized;
}

function sumNameLetters(name: string): { expression: number; soulUrge: number; personality: number } {
  let expressionSum = 0;
  let soulUrgeSum = 0;
  let personalitySum = 0;

  for (const char of name) {
    if (char === " ") continue;
    const value = pythagoreanValue(char);
    expressionSum += value;
    if (VOWELS.has(char)) {
      soulUrgeSum += value;
    } else {
      personalitySum += value;
    }
  }

  return {
    expression: reduceNumber(expressionSum),
    soulUrge: reduceNumber(soulUrgeSum),
    personality: reduceNumber(personalitySum),
  };
}

function buildPsychMatrix(birthDigits: string): {
  digitCounts: Record<string, number>;
  dominantDigits: number[];
  missingDigits: number[];
  totalEnergyScore: number;
} {
  const counts: Record<string, number> = {
    "1": 0,
    "2": 0,
    "3": 0,
    "4": 0,
    "5": 0,
    "6": 0,
    "7": 0,
    "8": 0,
    "9": 0,
  };

  for (const digit of birthDigits) {
    if (digit >= "1" && digit <= "9") {
      counts[digit] = (counts[digit] ?? 0) + 1;
    }
  }

  const dominantDigits: number[] = [];
  const missingDigits: number[] = [];
  let totalEnergyScore = 0;

  for (let d = 1; d <= 9; d += 1) {
    const key = d.toString();
    const count = counts[key] ?? 0;
    totalEnergyScore += count * d;
    if (count === 0) {
      missingDigits.push(d);
    }
    if (count >= 2) {
      dominantDigits.push(d);
    }
  }

  return {
    digitCounts: counts,
    dominantDigits,
    missingDigits,
    totalEnergyScore,
  };
}

export function buildNumerologyBaseline(params: {
  fullName: string;
  birthDate: string;
  calcVersion: string;
}): NumerologyBaseline {
  const normalizedName = normalizeName(params.fullName);
  const normalizedBirthDate = normalizeBirthDate(params.birthDate);

  if (!normalizedName) {
    throw new Error("full_name is required to build numerology baseline.");
  }

  const birthDate = new Date(`${normalizedBirthDate}T00:00:00Z`);
  const day = birthDate.getUTCDate();
  const month = birthDate.getUTCMonth() + 1;
  const year = birthDate.getUTCFullYear();

  const dayDigits = day.toString().padStart(2, "0");
  const monthDigits = month.toString().padStart(2, "0");
  const yearDigits = year.toString().padStart(4, "0");
  const allBirthDigits = `${dayDigits}${monthDigits}${yearDigits}`;

  const lifePath = reduceNumber(
    allBirthDigits
      .split("")
      .map((d) => Number(d))
      .reduce((acc, curr) => acc + curr, 0),
  );

  const { expression, soulUrge, personality } = sumNameLetters(normalizedName);

  const birthday = reduceNumber(day);
  const attitude = reduceNumber(day + month);
  const maturity = reduceNumber(lifePath + expression);

  const monthReduced = reduceNumber(month);
  const dayReduced = reduceNumber(day);
  const yearReduced = reduceNumber(
    yearDigits
      .split("")
      .map((d) => Number(d))
      .reduce((acc, curr) => acc + curr, 0),
  );

  const peaks: PeakChallenge = {
    first: reduceNumber(monthReduced + dayReduced),
    second: reduceNumber(dayReduced + yearReduced),
    third: reduceNumber(reduceNumber(monthReduced + dayReduced) + reduceNumber(dayReduced + yearReduced)),
    fourth: reduceNumber(monthReduced + yearReduced),
  };

  const challenges: PeakChallenge = {
    first: reduceNumber(Math.abs(dayReduced - monthReduced), false),
    second: reduceNumber(Math.abs(dayReduced - yearReduced), false),
    third: reduceNumber(
      Math.abs(
        reduceNumber(Math.abs(dayReduced - monthReduced), false) -
          reduceNumber(Math.abs(dayReduced - yearReduced), false),
      ),
      false,
    ),
    fourth: reduceNumber(Math.abs(monthReduced - yearReduced), false),
  };

  const psych = buildPsychMatrix(allBirthDigits);

  return {
    calc_version: params.calcVersion,
    generated_at: new Date().toISOString(),
    input: {
      full_name: params.fullName,
      birth_date: normalizedBirthDate,
      normalized_name: normalizedName,
    },
    core_numbers: {
      life_path: lifePath,
      expression,
      soul_urge: soulUrge,
      personality,
      birthday,
      attitude,
      maturity,
    },
    psych_matrix: {
      digit_counts: psych.digitCounts,
      dominant_digits: psych.dominantDigits,
      missing_digits: psych.missingDigits,
      total_energy_score: psych.totalEnergyScore,
    },
    cycle_markers: {
      peaks,
      challenges,
    },
  };
}
