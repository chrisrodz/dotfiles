---
description: Review technical documents against clarity and brevity principles
---

Review the provided technical document (commit message, PR description, spec, announcement, documentation, etc.) against these principles:

## Review Criteria

### 1. Brevity & Conciseness

- OK **Good**: As short as possible while conveying the key point
- WARN **Needs work**: Could be condensed without losing essential meaning
- FAIL **Poor**: Contains verbose explanations, unnecessary context, or redundant information

**Check**: Can this be said in fewer words? Are there subtle details that could be omitted?

### 2. Frontloading Key Information

- OK **Good**: Most important point is in the title or first sentence
- WARN **Needs work**: Key point appears in the second paragraph
- FAIL **Poor**: Buries the lede with context/throat-clearing before getting to the point

**Check**: Will readers who only read the first sentence understand the main message?

### 3. Context Assumptions

- OK **Good**: Assumes appropriate background knowledge for the intended audience
- WARN **Needs work**: Assumes slightly too much or too little context
- FAIL **Poor**: Requires deep technical context that readers likely don't have, OR over-explains basics

**Check**: Is the reader likely to have the background knowledge needed to understand this?

### 4. Detail Level vs. Audience Size

- OK **Good**: Simple point for broad audience OR complex point for tiny audience (2-5 people)
- WARN **Needs work**: Moderate complexity for moderate audience
- FAIL **Poor**: Highly detailed technical content intended for a broad audience

**Check**: Does the detail level match the audience size?

### 5. Clarity of Core Message

- OK **Good**: Single, clear message that's unambiguous
- WARN **Needs work**: Main point is somewhat clear but could be sharper
- FAIL **Poor**: Multiple related ideas without a clear central thesis

**Check**: Can you state the core message in one simple sentence?

### 6. Realistic Expectations

- OK **Good**: Aims to convey a simple point or rough context
- WARN **Needs work**: Tries to create "shared understanding" of moderate complexity
- FAIL **Poor**: Attempts to transplant complete technical understanding or get everyone on the same page

**Check**: Are the goals realistic given that readers will skim/skip most content?

## Review Instructions

For the provided document:

1. **Evaluate each criterion** with a rating (OK/WARN/FAIL) and brief explanation
2. **Identify the core message**: State what you believe the main point is in one sentence
3. **Suggest improvements**:
   - What can be cut?
   - Should the opening be rewritten to frontload the key point?
   - Is the detail level appropriate for the likely audience?
   - What assumptions about reader knowledge should be reconsidered?
4. **Provide a rewrite** (if WARN or FAIL on multiple criteria):
   - Show a condensed version
   - Frontload the key information
   - Omit subtle details that consume attention budget

## Remember

- Readers will read the first sentence, skim the next, then stop or skim the rest
- Each point consumes a limited attention budget
- The goal is NOT to transplant your full understanding
- The goal IS to convey a simple, clear point efficiently
- Even communicating something obvious is high-leverage in large organizations
