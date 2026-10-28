# frozen_string_literal: true

require 'sleeping_king_studios/docs/jekyll'

RSpec.describe SleepingKingStudios::Docs::Jekyll do
  describe '.commands' do
    let(:expected) do
      [
        SleepingKingStudios::Docs::Jekyll::Commands::Clobber,
        SleepingKingStudios::Docs::Jekyll::Commands::Check,
        SleepingKingStudios::Docs::Jekyll::Commands::DocumentVersion,
        SleepingKingStudios::Docs::Jekyll::Commands::Generate,
        SleepingKingStudios::Docs::Jekyll::Commands::Update
      ]
    end

    include_examples 'should define class reader',
      :commands,
      -> { expected }
  end

  describe '.install_commands' do
    let(:expected) do
      [
        SleepingKingStudios::Docs::Jekyll::Commands::BackfillVersions,
        SleepingKingStudios::Docs::Jekyll::Commands::Install,
        SleepingKingStudios::Docs::Jekyll::Commands::InstallTemplates,
        SleepingKingStudios::Docs::Jekyll::Commands::InstallWorkflow
      ]
    end

    include_examples 'should define class reader',
      :install_commands,
      -> { expected }
  end
end
