# SPDX-License-Identifier: GPL-3.0-or-later
# Run with: brew ruby scripts/collect-airplay-sources.rb APP OUTPUT_DIRECTORY
require "formula"
require "fileutils"
require "digest"

app = Pathname.new(ARGV.fetch(0)).realpath
destination = Pathname.new(ARGV.fetch(1)).expand_path
destination.mkpath
manifest = JSON.parse((app/"Contents/Resources/airplay-build.json").read)
inventory = []
manifest.fetch("formulas").each do |entry|
  name, _, version = entry.rpartition("@")
  owner = HOMEBREW_CELLAR/name/version
  recipe = owner/".brew/#{name}.rb"
  formula = Formulary.factory(recipe)
  raise "Installed recipe version mismatch: #{entry}" unless formula.pkg_version.to_s == version
  target = destination/"#{name}-#{version}"
  target.mkpath
  FileUtils.cp(recipe, target/recipe.basename)
  puts "Collecting corresponding sources: #{entry}"
  resources = [formula.stable.resource, *formula.resources]
  resources.each_with_index do |resource, index|
    cached = resource.fetch(skip_patches: true)
    output = target/"#{index}-#{cached.basename}"
    if cached.directory?
      output = target/"#{index}-git-source.tar.gz"
      resource.stage do
        system("tar", "-czf", output.to_s, "--exclude=.git", ".", exception: true)
      end
    else
      FileUtils.cp(cached, output)
    end
    inventory << {formula: entry, url: resource.url, file: output.relative_path_from(destination).to_s,
                  sha256: Digest::SHA256.file(output).hexdigest}
  end
  formula.stable.resource.prepare_patches
  formula.stable.patches.each_with_index do |patch, index|
    patch.path = recipe if patch.is_a?(DATAPatch)
    output = target/"patch-#{index}.patch"
    if patch.external?
      FileUtils.cp(patch.fetch, output)
    elsif patch.is_a?(LocalPatch)
      # Bottles keep the formula, but may omit repository-local patch files.
      bottles = (HOMEBREW_CACHE/"downloads").glob("*--#{name}-*.bottle_manifest.json")
      metadata = bottles.map { |path| JSON.parse(path.read).fetch("annotations", {}) }
                        .find { |data| data["org.opencontainers.image.version"] == formula.version.to_s }
      raise "Missing bottle source revision for #{entry}" unless metadata
      revision = metadata.fetch("org.opencontainers.image.revision")
      raise "Invalid bottle revision" unless revision.match?(/\A[0-9a-f]{40}\z/)
      url = "https://raw.githubusercontent.com/Homebrew/homebrew-core/#{revision}/#{patch.file}"
      system("curl", "--fail", "--location", "--retry", "2", "--max-time", "120", "--silent", "--show-error",
             url, "--output", output.to_s, exception: true)
      inventory << {formula: entry, patch_source: url}
    else
      output.write(patch.contents)
    end
    inventory << {formula: entry, file: output.relative_path_from(destination).to_s,
                  sha256: Digest::SHA256.file(output).hexdigest}
  end
end
(destination/"sources.json").write(JSON.pretty_generate(inventory))
puts "Collected #{inventory.length} source archives/resources/patches."
