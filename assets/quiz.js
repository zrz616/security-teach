/* ---------------------------------------------------------------------------
 * quiz.js — 检索练习组件（retrieval practice）。
 * 即时反馈是重点：点错立刻知道错在哪，而不是课后对答案。
 *
 * 用法（纯声明式，无需写 JS）：
 *   <div class="quiz" data-answer="1">
 *     <p class="quiz__q">题干？</p>
 *     <button class="quiz__opt">选项一</button>
 *     <button class="quiz__opt">选项二</button>
 *     <p class="quiz__why" hidden>解析，引用来源链接。</p>
 *   </div>
 *
 * data-answer 是正确选项的 0-based 下标。选项字数尽量等长，且正确答案的位置
 * 在各题之间轮换——不要让格式泄漏答案。
 *
 * 可选：页面上放一个 <p data-quiz-total></p>，会自动显示总进度。
 * ------------------------------------------------------------------------- */

(() => {
  const quizzes = [...document.querySelectorAll('.quiz[data-answer]')];
  if (!quizzes.length) return;

  const tally = document.querySelector('[data-quiz-total]');
  let answered = 0;
  let correct = 0;

  const paintTally = () => {
    if (!tally) return;
    tally.textContent = `已答 ${answered} / ${quizzes.length} 题，答对 ${correct} 题。`;
  };
  paintTally();

  quizzes.forEach((quiz) => {
    const answer = Number(quiz.dataset.answer);
    const options = [...quiz.querySelectorAll('.quiz__opt')];
    const why = quiz.querySelector('.quiz__why');

    // 每题自己的反馈行（不要做成共享节点：appendChild 会把它挪走）
    const verdict = document.createElement('p');
    verdict.className = 'quiz__score';
    verdict.hidden = true;
    quiz.appendChild(verdict);

    options.forEach((opt, i) => {
      opt.addEventListener('click', () => {
        if (quiz.dataset.done === '1') return;
        quiz.dataset.done = '1';

        const isRight = i === answer;
        answered += 1;
        if (isRight) correct += 1;

        options.forEach((o, j) => {
          o.disabled = true;
          if (j === answer) o.classList.add('quiz__opt--correct');
          else if (j === i) o.classList.add('quiz__opt--wrong');
        });

        verdict.hidden = false;
        verdict.textContent = isRight
          ? '✓ 答对了。解析在下面。'
          : '✗ 不对，正确选项已标出。解析在下面。';
        if (why) why.hidden = false;
        paintTally();
      });
    });
  });
})();
