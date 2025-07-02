return {
  'milanglacier/minuet-ai.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  lazy         = true,
  event        = { "InsertEnter" },
  opts         = {

    provider = 'openai_fim_compatible',
    n_completions = 2, -- recommend for local model for resource saving
    -- I recommend beginning with a small context window size and incrementally
    -- expanding it, depending on your local computing power. A context window
    -- of 512, serves as an good starting point to estimate your computing
    -- power. Once you have a reliable estimate of your local computing power,
    -- you should adjust the context window to a larger value.
    context_window = 512,
    request_timeout = 10,
    provider_options = {
      openai_fim_compatible = {
        -- For Windows users, TERM may not be present in environment variables.
        -- Consider using APPDATA instead.
        api_key = 'TERM',
        name = 'Ollama',
        end_point = 'http://llm.a322b:11434/v1/completions',
        --model = 'qwen2.5-coder:32b',
        --model = 'qwen2.5-coder:14b',
        --model = 'qwen2.5-coder:7b',
        model = 'qwen2.5-coder:3b',
        optional = {
          max_tokens = 200,
          top_p = 0.9,
        },
      },
    },
  },
  config       = function(_, opts)
    require('minuet').setup(opts)
  end,


}
