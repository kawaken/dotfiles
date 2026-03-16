# PR Review Skill
1. Read the PR diff only (use `git diff main...HEAD` or provided diff)
2. Only comment on files in the diff - never mention out-of-scope files
3. Check for: security issues, logic errors, missing tests, naming consistency
4. Output format: list findings as [CRITICAL], [SUGGESTION], or [NIT]
5. If no issues found, say "クリーンなPRです" with brief summary
