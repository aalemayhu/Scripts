#!/usr/bin/env deno run --allow-read
import { exists } from "https://deno.land/std/fs/mod.ts";

async function main() {
  const isFedora = await exists('/etc/fedora-release');
  if (isFedora) {
    const commands = ['update', 'upgrade', 'clean packages', 'autoremove'];
    for (const cmd of commands) {
      await Deno.run({args: ['dnf', cmd]});
    }
    return;
  }

  const isDebian = await exists('/etc/debian-release');
  let hasAptGet = isDebian

  if (!isDebian) {
    try {
      await Deno.run({args: ['apt-get', '--version']});
      hasAptGet = true;
    } catch (error) {}
  }

  if (isDebian || hasAptGet) {
    await Deno.run({ args: ['apt-get', 'update'] });
    await Deno.run({ args: ['apt-get', 'upgrade -y'] });
    await Deno.run({ args: ['apt-get', 'upgrade -y'] });
    await Deno.run({ args: ['apt-get', 'autoclean'] });
    await Deno.run({ args: ['apt-get', 'autoremove'] });
    return;
  }

  console.error('fatal: unsupported system');
  Deno.exit(1);
}


main()